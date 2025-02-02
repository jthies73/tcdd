require "rqrcode"
require "chunky_png"

class QrCodesController < ApplicationController
  def show
    qr_code = RQRCode::QRCode.new("https://trashcan-dresden.yafa.app", size: 4, level: :h)
    png = qr_code.as_png(
      resize_gte_to: false,
      resize_exactly_to: false,
      fill: "white",
      color: "black",
      size: 1000,
      border_modules: 4,
      module_px_size: 6,
      file: nil # path to write
    )
    @qr_code_data = Base64.encode64(png.to_s)
  end
end
