Dir['activerecord_patch/**/*.rb', base: __dir__].each do |filename|
  require_relative filename
end
