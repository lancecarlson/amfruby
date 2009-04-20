LIB_PATH = File.join(RAILS_ROOT, %w(vendor swc))
FLEX_FILES = File.join(RAILS_ROOT, %w(app flex))

namespace :flex do  
  desc "Build & Preview"
  task :build do
    build_mxml = File.join(FLEX_FILES, "Chat.mxml")
    output = File.join(RAILS_ROOT, "public/bin/Chat.swf")
    puts `mxmlc #{build_mxml} -output #{output} -compiler.incremental -library-path+=#{LIB_PATH}`
    system("open", "http://localhost:3000/bin/Chat.swf")
  end
end
