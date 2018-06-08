module RailsGuides
  class Markdown
    class Renderer < Redcarpet::Render::HTML
      cattr_accessor :edge, :version

      def block_code(code, language)
        <<-HTML
<div class="code_container">
<pre class="brush: #{brush_for(language)}; gutter: false; toolbar: true;">
#{ERB::Util.h(code)}
</pre>
</div>
HTML
      end

      def link(url, title, content)
        if url.start_with?("http://api.rubyonrails.org")
          %(<a href="#{api_link(url)}">#{content}</a>)
        elsif title
          %(<a href="#{url}" title="#{title}">#{content}</a>)
        else
          %(<a href="#{url}">#{content}</a>)
        end
      end

      def header(text, header_level)
        # Always increase the heading level by 1, so we can use h1, h2 heading in the document
        header_level += 1

        %(<h#{header_level}>#{text}</h#{header_level}>)
      end

      def paragraph(text)
        if text =~ %r{^NOTE:\s+Defined\s+in\s+<code>(.*?)</code>\.?$}
          %(<div class="note"><p>Defined in <code><a href="#{github_file_url($1)}">#{$1}</a></code>.</p></div>)
        elsif text =~ /^(TIP|IMPORTANT|CAUTION|WARNING|NOTE|INFO|TODO|DATE)[.:]/
          convert_notes(text)
        elsif text.include?("DO NOT READ THIS FILE ON GITHUB")
        elsif text =~ /^\[<sup>(\d+)\]:<\/sup> (.+)$/
          linkback = %(<a href="#footnote-#{$1}-ref"><sup>#{$1}</sup></a>)
          %(<p class="footnote" id="footnote-#{$1}">#{linkback} #{$2}</p>)
        elsif text =~ /^CHORD:\s+(.+)$/
          shape, root, name = $1.split("\s")

          root ||= shape.chars.find_index { |char| char.downcase != "x" }.to_i + 1

          chord_code(shape, root, name)
        elsif text =~ /^PDF:\s+(.+)$/
          doc_code(:pdf, $1)
        elsif text =~ /^FLOW:/
          text = text.gsub("FLOW:", "")
          flowchart_code(text)
        elsif text =~ /^TREE:/
          config = text.gsub("TREE:", "")
          tree_code(config)
        else
          text = convert_footnotes(text)
          "<p>#{text}</p>"
        end
      end

      def tree_code(config)
        hex_id = SecureRandom.hex
        config = CGI.unescapeHTML(config.strip)

        hash = begin
                 eval(config)
               rescue Exception => ex
                 raise "#{config}不对 不能解析为hash. #{ex.message}"
               end

        json = {
          chart: {
            container: "##{hex_id}",
            rootOrientation: hash.delete(:direction) || "WEST",
            siblingSeparation:   40,
            subTeeSeparation:    30,
            connectors: {
              type: 'step',
              style: {
                stroke: '#bbb',
                "arrow-end" => 'block-wide-long'
              }
            },
            node: {
              HTMLclass: 'nodeChart'
            }
          }
        }.merge(nodeStructure: hash).to_json

        <<-HTML
<div class="tree_chart" style="display:none" id="#{hex_id}">
  #{json}
</div>
HTML
      end

      def flowchart_code(code)
        <<-HTML
<div class="flowchart" style="display:none" id="#{SecureRandom.hex}">
  #{code.strip}
</div>
HTML
      end

      def doc_code(doc_type, name)
        <<-HTML
<div class="google_doc" style="display:none" url="https://github.com/dengqinghua/roses/raw/master/assets/doc/#{name}.#{doc_type}">
</div>
HTML
      end

      ##
      # ==== Description
      #   参考:
      #
      #   - https://github.com/andygock/chordy-svg
      #   - https://chords.gock.net/chords/dominant-eleventh
      #
      def chord_code(shape, root, name)
        <<-HTML
<div class='chord'>
  <div class='chordSvg' data-shape='#{shape}' data-root='#{root}' data-name='#{name}'> </div>

  <div class='play'>
    <span class="play-arpeggio" "data-notes"="">
      <img src="images/speaker.png" height="11" width="11"> 慢速(Arpeggio)
    </span>

    <span class="play-strum" "data-notes"="">
      <img src="images/speaker.png" height="11" width="11"> 中速(Strum)
    </span>

    <span class="play-tone" "data-notes"="">
      <img src="images/speaker.png" height="11" width="11"> 快速(Tone)
    </span>
  </div>
</div>
HTML
      end

      private

        def convert_footnotes(text)
          text.gsub(/\[<sup>(\d+)\]<\/sup>/i) do
            %(<sup class="footnote" id="footnote-#{$1}-ref">) +
              %(<a href="#footnote-#{$1}">#{$1}</a></sup>)
          end
        end

        def brush_for(code_type)
          case code_type
          when "ruby", "sql", "plain", "java", "shell", "c", "cpp", "bash", "csharp", "css", "js", "py", "sql", "scala", "xml", "go", "golang"
            code_type
          when "erb", "html+erb"
            "ruby; html-script: true"
          when "go" # 使用java的关键词, 已经在 syntaxhighlighter 的 brush-java 部分做了关键词的修改
            "java"
          when "music"
            "ruby"
          when "html"
            "xml" # HTML is understood, but there are .xml rules in the CSS
          else
            "plain"
          end
        end

        def convert_notes(body)
          # The following regexp detects special labels followed by a
          # paragraph, perhaps at the end of the document.
          #
          # It is important that we do not eat more than one newline
          # because formatting may be wrong otherwise. For example,
          # if a bulleted list follows the first item is not rendered
          # as a list item, but as a paragraph starting with a plain
          # asterisk.
          body.gsub(/^(TIP|IMPORTANT|CAUTION|WARNING|NOTE|INFO|TODO|DATE|PDF|CHORD|FLOW)[.:](.*?)(\n(?=\n)|\Z)/m) do
            css_class = \
              case $1
              when "CAUTION", "IMPORTANT"
                "warning"
              when "TIP"
                "info"
              else
                $1.downcase
              end

            %(<div class="#{css_class}"><p>#{$2.strip}</p></div>)
          end
        end

        def github_file_url(file_path)
          tree = version || edge

          root = file_path[%r{(\w+)/}, 1]
          path = \
            case root
            when "abstract_controller", "action_controller", "action_dispatch"
              "actionpack/lib/#{file_path}"
            when /\A(action|active)_/
              "#{root.sub("_", "")}/lib/#{file_path}"
            else
              file_path
            end

          "https://github.com/rails/rails/tree/#{tree}/#{path}"
        end

        def api_link(url)
          if url =~ %r{http://api\.rubyonrails\.org/v\d+\.}
            url
          elsif edge
            url.sub("api", "edgeapi")
          else
            url.sub(/(?<=\.org)/, "/#{version}")
          end
        end
    end
  end
end
