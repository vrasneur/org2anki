#!/usr/bin/env ruby

require 'csv'
require 'optparse'
require 'org-ruby'

def generate_csv(options)
  parser = Orgmode::Parser.load(options[:orgfile])
  history = []

  CSV.open(options[:csvfile], 'w', col_sep: ';') do |csv|
    parser.headlines.each do |headline|
      lines = []

      history.delete_if { |level, text| level >= headline.level }
      unless options[:skipfirst] and headline.level == 1
        history << [headline.level, "* #{headline.output_text}"]
      end

      headline.body_lines.each_with_index do |line, idx|
        next if idx == 0

        output = line.output_text.strip
        output.insert(0, '- ') if line.plain_list?

        lines << output
      end

      unless history.empty? or lines.empty?
        lines = lines.join("\n").strip
        csv << [history.map{ |a, b| b }.join("\n"), lines] unless lines.empty?
      end
    end
  end
end

def get_options()
  options = {}

  opt = OptionParser.new do |opts|
    opts.banner = "Usage: #$0 [options] file.org [file.csv]"
    opts.on('-s', '--skip-first', 'skip first headline') { options[:skipfirst] = true }
    opts.on('-f', '--force', 'overwrite an existing CSV file') {options[:force] = true }
  end
  opt.parse!

  options[:orgfile] = ARGV.shift
  opt.abort('need an Org file') unless options[:orgfile]
  opt.abort("the Org file '#{options[:orgfile]}' does not exist") unless File.exists?(options[:orgfile])

  options[:csvfile] = ARGV.shift
  unless options[:csvfile]
    options[:csvfile] = options[:orgfile].gsub(/\.org$/, '.csv')
  end

  opt.abort("Org file '#{options[:orgfile]}' and CSV file '#{options[:csvfile]}' are the same file!") if options[:orgfile] == options[:csvfile]
  opt.abort("the CSV file '#{options[:csvfile]}' already exists!") if File.exists?(options[:csvfile]) and not options[:force]

  options
end

options = get_options
generate_csv(options)
