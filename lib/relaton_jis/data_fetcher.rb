module RelatonJis
  class DataFetcher
    URL = "https://webdesk.jsa.or.jp/books/".freeze
    INDEX_FILE = "index-v1.yaml".freeze

    def initialize(output, format)
      @output = output
      @format = format
      @ext = format.sub("bibxml", "xml")
      @files = Set.new
      @queue = SizedQueue.new 10
      @threads = create_thread_pool 5
      @mutex = Mutex.new
    end

    def self.fetch(output: "data", format: "yaml")
      start_time = Time.now
      puts "Start fetching JIS data at #{start_time}"
      FileUtils.mkdir_p output
      new(output, format).fetch
      stop_time = Time.now
      puts "Fetching JIS data finished at #{stop_time}. It took #{stop_time - start_time} seconds."
    end

    def create_thread_pool(size)
      Array.new(size) do
        Thread.new do
          until (url = @queue.shift) == :END
            fetch_doc url
          end
        end
      end
    end

    def fetch_doc(url) # rubocop:disable Metrics/MethodLength
      attempts = 0
      begin
        bib = Scraper.new(url).fetch
      rescue StandardError => e
        attempts += 1
        if attempts < 5
          sleep 2
          retry
        else
          Util.warn "URL: #{url}"
          Util.warn "#{e.message}\n#{e.backtrace[0..6].join("\n")}"
        end
      else
        save_doc bib, url
      end
    end

    def fetch
      return unless initial_post

      resp = agent.get "#{URL}W11M0070/index"
      parse_page resp
      index.save
    end

    def initial_post
      return true if @initial_time && Time.now - @initial_time < 600

      body = { record: 0, dantai: "JIS", searchtype2: 1, status_1: 1, status_2: 2 }
      # body = { search_type: "KOKUNAI", all_search_flg: "all_search" }
      resp = agent.post "#{URL}W11M0270/index", body
      disp = JSON.parse resp.body
      @initial_time = Time.now
      disp["status"] || Util.warn("No results found for JIS")
    end

    def agent
      @agent ||= Mechanize.new
    end

    def parse_page(resp)
      while resp
        resp.xpath('//div[@class="blockGenaral"]/a').each { |a| @queue << a[:href] }
        offset = parse_offset resp
        break if offset >= count # no more pages

        resp = get_next_page(offset)
      end
      end_threads_and_wait
    end

    def parse_offset(resp) # rubocop:disable Metrics/AbcSize
      if resp.at('//*[@id="btnPaging"]') # first page
        @count = resp.at('//script[contains(.,"var count =")]').text.match(/var count = (\d+);/)[1]
        resp.at("//*[@id='offset']")[:value].to_i
      else
        script = resp.at("//script").text
        script.match(/\("offset"\)\.value = '(\d+)'/)[1].to_i
      end
    end

    def end_threads_and_wait
      @threads.size.times { @queue << :END }
      @queue.close
      @threads.each(&:join)
    end

    def count
      @count.to_i
    end

    def get_next_page(offset) # rubocop:disable Metrics/MethodLength
      attempts = 0
      begin
        if initial_post
          agent.post "#{URL}W11M0070/getAddList", search_type: "JIS", offset: offset
          # agent.post "#{URL}W11M0070/getAddList", search_type: "KOKUNAI", all_search_flg: "all_search", offset: offset
        end
      rescue StandardError => e
        attempts += 1
        if attempts < 5
          sleep 2
          retry
        else
          Util.warn "#{e.message}\n#{e.backtrace[0..6].join("\n")}"
        end
      end
    end

    def save_doc(bib, url) # rubocop:disable Metrics/MethodLength
      return unless bib

      id = bib.docidentifier.find(&:primary).id
      file = file id
      @mutex.synchronize do
        if @files.include?(file)
          Util.warn "File #{file} already exists. Duplication URL: #{url}"
        else
          @files << file
          File.write file, serialize(bib), encoding: "UTF-8"
          index.add_or_update id, file
        end
      end
    end

    def index
      @index ||= Relaton::Index.find_or_create :jis, file: INDEX_FILE
    end

    def file(id)
      name = id.gsub(/[:\/\s]/, "_")
      File.join @output, "#{name}.#{@ext}"
    end

    def serialize(bib)
      case @format
      when "yaml" then bib.to_hash.to_yaml
      when "xml" then bib.to_xml bibdata: true
      else bib.send "to_#{@format}"
      end
    end
  end
end
