# frozen_string_literal: true

model_page = '/3d/example-model/'
expect_match(model_page, %r{<model-viewer[^>]*src="/assets/3d/example-model/model\.glb"}, 'viewer with the model file')
expect_match(model_page, /<model-viewer[^>]*camera-controls/, 'camera controls')
expect_match(model_page, /<model-viewer[^>]*auto-rotate/, 'auto rotate')
expect_match(model_page, %r{<model-viewer[^>]*alt="3D model of Example model: &quot;Calibration&quot; Cube"}, 'viewer alt, escaped')
expect_match(model_page, %r{<model-viewer[^>]*poster="/assets/3d/example-model/1\.svg"}, 'cover as poster')
expect_match(model_page, %r{src="https://cdn\.jsdelivr\.net/npm/@google/model-viewer@4\.0\.0/dist/model-viewer\.min\.js"}, 'viewer script')
expect_match(model_page, %r{href="/assets/3d/example-model/model\.glb" download>Download \.glb</a>}, 'download link')

glb = File.join(SITE, 'assets/3d/example-model/model.glb')
FAILURES << 'model.glb: not a binary glTF file' unless File.file?(glb) && File.binread(glb, 4) == 'glTF'

# model-viewer sets height: 150px on :host. height: auto lets aspect-ratio set the height.
expect_match('/assets/css/style.css', /\.viewer model-viewer \{[^}]*height: auto;/, 'viewer height from aspect-ratio')

contra_page = '/3d/contra-heatmap/'
expect_match(contra_page, %r{<model-viewer[^>]*src="/assets/3d/contra-heatmap/model\.glb"}, 'Contra viewer with the GLB file')
expect_match(contra_page, %r{href="/assets/3d/contra-heatmap/contra-ahmetkorkmaz\.stl" download>Download \.stl</a>}, 'STL download link')
expect_match(contra_page, %r{<a class="tile tile-video" href="/assets/3d/contra-heatmap/video\.mp4" data-type="video"}, 'video tile links to the video')
expect_match(contra_page, %r{<video src="/assets/3d/contra-heatmap/video\.mp4" poster="/assets/3d/contra-heatmap/video-poster\.jpg" autoplay muted loop playsinline}, 'looping muted video')
expect_match(contra_page, %r{<a class="tile" href="/assets/3d/contra-heatmap/2\.webp" data-type="image"><img src="/assets/3d/contra-heatmap/2\.webp"}, 'photo tile links to the photo')
expect_match(contra_page, %r{property="og:image" content="https://ahmetkorkmaz3\.github\.io/assets/3d/contra-heatmap/og\.jpg"}, 'og_image before the transparent cover')
expect_match(contra_page, %r{<dt>Printer</dt>\s*<dd>Creality Ender 3 S1</dd>}, 'Contra printer fact')
expect_no_match(model_page, /<video/, 'no video without a video field')
%w[model.glb contra-ahmetkorkmaz.stl video.mp4 og.jpg 1.webp].each do |name|
  FAILURES << "contra-heatmap/#{name}: missing" unless File.file?(File.join(SITE, 'assets/3d/contra-heatmap', name))
end

# The photos are transparent, so a tile must give the background.
expect_match('/assets/css/style.css', /\.tile \{[^}]*background: var\(--surface\);/, 'tile background for transparent photos')
expect_match('/assets/js/main.js', /className = 'lightbox'/, 'lightbox script')
