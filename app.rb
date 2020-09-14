require "mini_magick"
require 'json'

class PdfFile

  attr_reader :file_name, :page

  def initialize(file_name, page)
    @file_name = file_name
    @page = page
  end

  def read
    file.read
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
        {"Content-Type" => "text/plain"}, [file.read]
      ]

    else

      [
        404,
        {"Content-Type" => "text/plain"}, ["Not found"]
      ]

    end

  end

end
