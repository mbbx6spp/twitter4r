module Spec
  module Runner
    module Formatter
      class HtmlFormatter < BaseTextFormatter
        
        def initialize(output)
          super
          @current_behaviour_number = 0
          @current_example_number = 0
        end

        # The number of the currently running behaviour
        def current_behaviour_number
          @current_behaviour_number
        end
        
        # The number of the currently running example
        def current_example_number
          @current_example_number
        end
        
        def start(example_count)
          @example_count = example_count

          @output.puts html_header
          @output.puts report_header
          @output.flush
        end

        def add_behaviour(name)
          @behaviour_red = false
          @behaviour_red = false
          @current_behaviour_number += 1
          unless current_behaviour_number == 1
            @output.puts "  </dl>"
            @output.puts "</div>"
          end
          @output.puts "<div class=\"behaviour\">"
          @output.puts "  <dl>"
          @output.puts "  <dt id=\"behaviour_#{current_behaviour_number}\">#{escape(name)}</dt>"
          @output.flush
        end

        def start_dump
          @output.puts "  </dl>"
          @output.puts "</div>"
          @output.flush
        end

        def example_passed(name)
          @current_example_number += 1
          move_progress
          @output.puts "    <dd class=\"spec passed\"><span class=\"passed_spec_name\">#{escape(name)}</span></dd>"
          @output.flush
        end

        def example_failed(name, counter, failure)
          extra = extra_failure_content(failure)
          
          @current_example_number += 1
          @output.puts "    <script type=\"text/javascript\">makeRed('rspec-header');</script>" unless @header_red
          @header_red = true
          @output.puts "    <script type=\"text/javascript\">makeRed('behaviour_#{current_behaviour_number}');</script>" unless @behaviour_red
          @behaviour_red = true
          move_progress
          @output.puts "    <dd class=\"spec failed\">"
          @output.puts "      <span class=\"failed_spec_name\">#{escape(name)}</span>"
          @output.puts "      <div class=\"failure\" id=\"failure_#{counter}\">"
          @output.puts "        <div class=\"message\"><pre>#{escape(failure.exception.message)}</pre></div>" unless failure.exception.nil?
          @output.puts "        <div class=\"backtrace\"><pre>#{format_backtrace(failure.exception.backtrace)}</pre></div>" unless failure.exception.nil?
          @output.puts extra unless extra == ""
          @output.puts "      </div>"
          @output.puts "    </dd>"
          @output.flush
        end

        def example_not_implemented(name)
          @current_example_number += 1
          @output.puts "    <script type=\"text/javascript\">makeYellow('rspec-header');</script>" unless @header_red
          @output.puts "    <script type=\"text/javascript\">makeYellow('behaviour_#{current_behaviour_number}');</script>" unless @behaviour_red
          move_progress
          @output.puts "    <dd class=\"spec not_implemented\"><span class=\"not_implemented_spec_name\">#{escape(name)}</span></dd>"
          @output.flush
        end
        # Override this method if you wish to output extra HTML for a failed spec. For example, you
        # could output links to images or other files produced during the specs.
        #
        def extra_failure_content(failure)
          "    <pre class=\"ruby\"><code>#{@snippet_extractor.snippet(failure.exception)}</code></pre>"
        end
        
        def move_progress
          percent_done = @example_count == 0 ? 100.0 : (current_example_number.to_f / @example_count.to_f * 1000).to_i / 10.0
          @output.puts "    <script type=\"text/javascript\">moveProgressBar('#{percent_done}');</script>"
          @output.flush
        end
        
        def escape(string)
          string.gsub(/&/n, '&amp;').gsub(/\"/n, '&quot;').gsub(/>/n, '&gt;').gsub(/</n, '&lt;')
        end

        def dump_failure(counter, failure)
        end

        def dump_summary(duration, example_count, failure_count, not_implemented_count)
          if @dry_run
            totals = "This was a dry-run"
          else
            totals = "#{example_count} example#{'s' unless example_count == 1}, #{failure_count} failure#{'s' unless failure_count == 1}"
            totals << ", #{not_implemented_count} not implemented" if not_implemented_count > 0  
          end
          @output.puts "<script type=\"text/javascript\">document.getElementById('duration').innerHTML = \"Finished in <strong>#{duration} seconds</strong>\";</script>"
          @output.puts "<script type=\"text/javascript\">document.getElementById('totals').innerHTML = \"#{totals}\";</script>"
          @output.puts "</div>"
          @output.puts "</div>"
          @output.puts "</body>"
          @output.puts "</html>"
          @output.flush
        end

        def html_header 
          <<-EOF
<?xml version="1.0" encoding="iso-8859-1"?>
<!DOCTYPE html
     PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
     "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
  <title>RSpec results</title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
  <meta http-equiv="Expires" content="-1" />
  <meta http-equiv="Pragma" content="no-cache" />
  <style type="text/css">
  body {
    margin: 0;
    padding: 0;
    background: #fff;
    font-size: 80%;
  }
  </style>
</head>
<body>
EOF
        end

        def report_header
          <<-EOF
<div class="rspec-report">
  <script type="text/javascript">
    // <![CDATA[
#{global_scripts}
    // ]]>
  </script>
  <style type="text/css">
#{global_styles}
  </style>

<div id="rspec-header">
  <h1>RSpec Results</h1>

  <div id="summary">
    <p id="totals">&nbsp;</p>
    <p id="duration">&nbsp;</p>
  </div>
</div>

<div class="results">
EOF
        end

        def global_scripts
          <<-EOF
function moveProgressBar(percentDone) {
  document.getElementById("rspec-header").style.width = percentDone +"%";
}
function makeRed(element_id) {
  document.getElementById(element_id).style.background = '#C40D0D';
  document.getElementById(element_id).style.color = '#FFFFFF';
}

function makeYellow(element_id) {
  if (element_id == "rspec-header" && document.getElementById(element_id).style.background != '#C40D0D')
  {
    document.getElementById(element_id).style.background = '#FAF834';
    document.getElementById(element_id).style.color = '#000000';
  }
  else
  {
    document.getElementById(element_id).style.background = '#FAF834';
    document.getElementById(element_id).style.color = '#000000';
  }
}
EOF
        end
        
        def global_styles
          <<-EOF
#rspec-header {
  background: #65C400; color: #fff;
}

.rspec-report h1 {
  margin: 0px 10px 0px 10px;
  padding: 10px;
  font-family: "Lucida Grande", Helvetica, sans-serif;
  font-size: 1.8em;
}

#summary {
  margin: 0; padding: 5px 10px;
  font-family: "Lucida Grande", Helvetica, sans-serif;
  text-align: right;
  position: absolute;
  top: 0px;
  right: 0px;
}

#summary p {
  margin: 0 0 0 2px;
}

#summary #totals {
  font-size: 1.2em;
}

.behaviour {
  margin: 0 10px 5px;
  background: #fff;
}

dl {
  margin: 0; padding: 0 0 5px;
  font: normal 11px "Lucida Grande", Helvetica, sans-serif;
}

dt {
  padding: 3px;
  background: #65C400;
  color: #fff;
  font-weight: bold;
}

dd {
  margin: 5px 0 5px 5px;
  padding: 3px 3px 3px 18px;
}

dd.spec.passed {
  border-left: 5px solid #65C400;
  border-bottom: 1px solid #65C400;
  background: #DBFFB4; color: #3D7700;
}

dd.spec.failed {
  border-left: 5px solid #C20000;
  border-bottom: 1px solid #C20000;
  color: #C20000; background: #FFFBD3;
}

dd.spec.not_implemented {
  border-left: 5px solid #FAF834;
  border-bottom: 1px solid #FAF834;
  background: #FCFB98; color: #131313;
}

.backtrace {
  color: #000;
  font-size: 12px;
}

a {
  color: #BE5C00;
}

/* Ruby code, style similar to vibrant ink */
.ruby {
  font-size: 12px;
  font-family: monospace;
  color: white;
  background-color: black;
  padding: 0.1em 0 0.2em 0;
}

.ruby .keyword { color: #FF6600; }
.ruby .constant { color: #339999; }
.ruby .attribute { color: white; }
.ruby .global { color: white; }
.ruby .module { color: white; }
.ruby .class { color: white; }
.ruby .string { color: #66FF00; }
.ruby .ident { color: white; }
.ruby .method { color: #FFCC00; }
.ruby .number { color: white; }
.ruby .char { color: white; }
.ruby .comment { color: #9933CC; }
.ruby .symbol { color: white; }
.ruby .regex { color: #44B4CC; }
.ruby .punct { color: white; }
.ruby .escape { color: white; }
.ruby .interp { color: white; }
.ruby .expr { color: white; }

.ruby .offending { background-color: gray; }
.ruby .linenum {
	width: 75px;
	padding: 0.1em 1em 0.2em 0;
	color: #000000;
	background-color: #FFFBD3;
}
EOF
        end
      end
    end
  end
end
