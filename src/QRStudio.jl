module QRStudio

using QML
import ZXingCPP: ZXing_BarcodeFormatToString, format, read_barcodes, text
using ZXingCPP

using ImageCore
import ImageShow
import ImageIO
import FileIO: load

QML_DIR = Base.pkgdir(@__MODULE__, "qml")
# QML_DIR = joinpath(dirname(@__DIR__), "qml")

@kwdef struct Detection
    content::String
    format::String
end

function create_barcode_image(content::String, barcode_format::ZXing_BarcodeFormat; kwargs...)
    co = CreatorOptions(barcode_format)
    bc = Barcode(content, co)

    scale = if barcode_format == ZXing_BarcodeFormat_QRCode
        10
    else
        3
    end
    wo = WriterOptions(; scale = scale)
    # wo = WriterOptions(; kwargs...)
    zimg = write_barcode_to_image(bc, wo)

    # img = Matrix(zimg)
    #
    d = ZXingCPP.data(zimg)
    nv = normedview(d)
    pimg = permutedims(nv)
    img = Gray.(pimg)

    return img
end

function create_barcode_image(content::String, barcode_format::String; kwargs...)
    fmt = ZXing_BarcodeFormatFromString(barcode_format)
    return create_barcode_image(content, fmt; kwargs...)
end


function barcode_display(d::JuliaDisplay, content::QString, barcode_format::QString)
    img = create_barcode_image(String(content), String(barcode_format))
    h, w = size(img)
    display(d, img)
    return [h, w]
end


function detect(image_path::AbstractString)
    img = load(image_path)
    bcs = read_barcodes(img)
    result = []
    for bc in bcs
        content = text(bc)
        fmt = unsafe_string(ZXing_BarcodeFormatToString(format(bc)))
        push!(result, [content, fmt])
    end
    # result = [
    #     JuliaItemModel(
    #         Detection(
    #             content = text(bc),
    #             format = string(format(bc))
    #         )
    #     ),
    #     # Dict(
    #     #     "content" => text(bc)
    #     # ),
    # ]

    return result
end


function @main(ARGS)

    @qmlfunction detect barcode_display

    qml_file = joinpath(QML_DIR, "main.qml")
    loadqml(qml_file)

    return exec()
end

export main

end
