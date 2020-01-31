java_extension = ".java"

scala_extension = ".scala"

srcjar_extension = ".srcjar"

def get_files_with_extension(ctx, extension):
    return [
        f
        for f in ctx.files.srcs
        if f.basename.endswith(extension)
    ]
