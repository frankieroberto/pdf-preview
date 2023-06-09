require "mini_magick"
require 'json'

class PdfFile

  attr_reader :file_name, :page

  def initialize(file_name, page)
    @file_name = file_name
    @page = page
  end

  def read

    MiniMagick::Tool::Convert.new do |convert|
      convert.background "white"
      convert.flatten
      convert.density 400
      convert.quality 400
      convert.resize("2000x2000")
      convert << file.pages.first.path
      convert << "png8:/tmp/123"
    end

    File.open("/tmp/123").read
  end

  private

  def file
    url = "#{ENV.fetch('ORIGIN_URL')}/#{file_name}/#{page}"
    puts url
    @file ||= MiniMagick::Image.open("#{ENV.fetch('ORIGIN_URL')}/#{file_name}/#{page}")
    # @file.resize "100x100"
  end

end


class PdfRenderApp

  REGEX = /\A\/([^\/]+)\/((?:\d+|info))\z/

  def call(env)

    req = Rack::Request.new(env)

    puts req.path_info

    path_match = req.path_info.match(REGEX)

    if path_match

      file_name = path_match[1]
      page = path_match[2]

      file = PdfFile.new(file_name, page)

      [
        200,
        {
          "Content-Type" => "image/png",
          "Cache-Control" => "max-age=31536000"
        }, [file.read]
      ]

    else

      [
        404,
        {"Content-Type" => "text/plain"}, ["Not found"]
      ]

    end

  end

end
