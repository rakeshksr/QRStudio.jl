module QRStudio

import FileIO: load, save
import ImageCore: Gray, N0f8
import ImageIO

import QML:
    @qmlfunction,
    Format_RGB888,
    Image,
    ImageProvider,
    QImage,
    QString,
    QUrlAllocated,
    addImageProvider,
    exec,
    init_qmlapplicationengine,
    loadqml,
    toLocalFile

import ZXingCPP:
    Barcode,
    ZXing_BarcodeFormat,
    ZXing_BarcodeFormat_QRCode,
    format,
    position,
    read_barcodes,
    text,
    write_barcode_to_image

QML_DIR = Base.pkgdir(@__MODULE__, "qml")
# QML_DIR = joinpath(dirname(@__DIR__), "qml")

const BARCODE_PROVIDER_NAME = "barcodes"
const EMPTY_PREVIEW_SIZE = 300
const _barcode_buffer = Ref(Vector{UInt8}())
const _barcode_width = Ref(EMPTY_PREVIEW_SIZE)
const _barcode_height = Ref(EMPTY_PREVIEW_SIZE)
const _barcode_revision = Ref(0)
const _latest_barcode_image = Ref{Union{Nothing, Matrix{Gray{N0f8}}}}(nothing)

# @kwdef struct Detection
#     content::String
#     format::String
#     top_left_x::Int
#     top_left_y::Int
#     top_right_x::Int
#     top_right_y::Int
#     bottom_right_x::Int
#     bottom_right_y::Int
#     bottom_left_x::Int
#     bottom_left_y::Int
# end

function create_barcode_image(content::String, barcode_format::ZXing_BarcodeFormat; kwargs...)
    bc = Barcode(content, barcode_format)

    scale = if barcode_format == ZXing_BarcodeFormat_QRCode
        10
    else
        3
    end
    zimg = write_barcode_to_image(bc, scale=scale)
    img = Matrix(zimg)
    return img
end

function create_barcode_image(content::String, barcode_format::String; kwargs...)
    fmt = ZXing_BarcodeFormat(barcode_format)
    return create_barcode_image(content, fmt; kwargs...)
end


function make_qimage_rgb888_buffer(img::AbstractMatrix{Gray{N0f8}})
    height, width = size(img)
    bytes_per_line = 3 * width
    buffer = Vector{UInt8}(undef, height * bytes_per_line)

    @inbounds for y in 1:height
        row_offset = (y - 1) * bytes_per_line
        for x in 1:width
            value = reinterpret(UInt8, img[y, x].val)
            pixel_offset = row_offset + 3 * (x - 1)
            buffer[pixel_offset + 1] = value
            buffer[pixel_offset + 2] = value
            buffer[pixel_offset + 3] = value
        end
    end

    return buffer, width, height
end

function make_qimage_rgb888_buffer(img::AbstractMatrix)
    return make_qimage_rgb888_buffer(Gray{N0f8}.(img))
end

function set_barcode_buffer!(buffer::Vector{UInt8}, width::Integer, height::Integer)
    _barcode_buffer[] = buffer
    _barcode_width[] = Int(width)
    _barcode_height[] = Int(height)
    _barcode_revision[] += 1
    return "image://$(BARCODE_PROVIDER_NAME)/current?rev=$(_barcode_revision[])"
end

function generate_barcode_image(content::QString, barcode_format::QString)
    img = create_barcode_image(String(content), String(barcode_format))
    _latest_barcode_image[] = Gray{N0f8}.(img)
    buffer, width, height = make_qimage_rgb888_buffer(img)
    source = set_barcode_buffer!(buffer, width, height)
    return [width, height, source]
end

function save_generated_barcode(path::AbstractString)
    image = _latest_barcode_image[]
    image === nothing && return false
    save(path, image)
    return true
end

function save_generated_barcode(path::QString)
    return save_generated_barcode(String(path))
end

function save_generated_barcode(url::QUrlAllocated)
    return save_generated_barcode(toLocalFile(url))
end

function barcode_image_callback(_, _, _)
    image = QImage(pointer(_barcode_buffer[]), _barcode_width[], _barcode_height[], 3 * _barcode_width[], Format_RGB888)
    return deepcopy(image), _barcode_width[], _barcode_height[]
end

function detect(url::QUrlAllocated)
    path = toLocalFile(url)
    return detect(path)
end

function detect(image_path::AbstractString)
    img = load(image_path)
    bcs = read_barcodes(img)
    result = []
    for bc in bcs
        content = text(bc)
        fmt = string(format(bc))
        pos = position(bc)
        # To-Do replace Array with Struct
        # det = Detection(
        #     content,
        #     fmt,
        #     pos.topLeft.x,
        #     pos.topLeft.y,
        #     pos.topRight.x,
        #     pos.topRight.y,
        #     pos.bottomRight.x,
        #     pos.bottomRight.y,
        #     pos.bottomLeft.x,
        #     pos.bottomLeft.y,
        # )
        det = [
            content,
            fmt,
            pos.topLeft.x,
            pos.topLeft.y,
            pos.topRight.x,
            pos.topRight.y,
            pos.bottomRight.x,
            pos.bottomRight.y,
            pos.bottomLeft.x,
            pos.bottomLeft.y,
        ]
        push!(result, det)
    end
    return result
end


function (@main)(ARGS)

    @qmlfunction detect generate_barcode_image save_generated_barcode

    qml_file = joinpath(QML_DIR, "main.qml")
    set_barcode_buffer!(fill(UInt8(255), EMPTY_PREVIEW_SIZE * EMPTY_PREVIEW_SIZE * 3), EMPTY_PREVIEW_SIZE, EMPTY_PREVIEW_SIZE)
    engine = init_qmlapplicationengine()
    addImageProvider(engine, BARCODE_PROVIDER_NAME, ImageProvider(Image, barcode_image_callback))
    # detectionsModel = JuliaItemModel(detections)
    # loadqml(qml_file; detectionsModel)
    loadqml(engine, qml_file)

    return exec()
end

export main

end
