require "baked_file_system"

class AssetsStorage extend BakedFileSystem
  bake_folder "./assets"
end

class AssetsHandler include HTTP::Handler
  @baked_fs : BakedFileSystem
  @fallthrough : Bool

  def initialize(storage, fallthrough = true)
    @baked_fs = storage
    @fallthrough = !!fallthrough
  end

  def call(context) : Nil
    unless context.request.method.in?("GET", "HEAD")
      if @fallthrough
        call_next(context)
      else
        context.response.status = :method_not_allowed
        context.response.headers.add("Allow", "GET, HEAD")
      end
      return
    end

    # TODO: Path prefix
    original_path = context.request.path.not_nil!
    is_dir_path = original_path.ends_with?("/")
    request_path = URI.decode(original_path)

    # TODO: Send not_modified if it wasn't midified

    context.response.content_type = MIME.from_filename(request_path.to_s, "application/octet-stream")

    file = @baked_fs.get?(request_path)
    if file
      IO.copy file, context.response
      return
    end

    if @fallthrough
      call_next(context)
    else
      context.response.status = :not_found
    end
  end
end
