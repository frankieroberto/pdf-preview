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
      convert.verbose
      convert.density(300)
      convert << open(url).read
      convert.background('white')
      convert.alpha('remove')
      convert << '/tmp/123'
    end

    File.open("/tmp/123").read
  end

  private

  def url
    "#{ENV.fetch('ORIGIN_URL')}/#{file_name}/#{page}"
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
        {"Content-Type" => "image/png"}, [file.read]
      ]

    else

      [
        404,
        {"Content-Type" => "text/plain"}, ["Not found"]
      ]

    end

  end

end
