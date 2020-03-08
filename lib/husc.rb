# -*- coding: utf-8 -*-
require 'mechanize'
require 'nokogiri'
require 'net/http'
require 'kconv'
require 'husc/version'


class Husc
  class Error < StandardError; end

  attr_reader :url, :html, :tables, :params, :code

  # 特殊配列
  class CrawlArray < Array

    def find(search)
      ## -----*----- 検索 -----*----- ##
      self.each do |e|
        if search.keys[0].to_s == 'inner'
          # inner_textが一致するか
          return e if e.inner_text == search.values[0]
        else
          # 属性が一致するか
          return e if e.attr(search.keys[0].to_s) == search.values[0]
        end
      end
    end

    def method_missing(method, *args)
      if self == []
        return eval("Husc.new(doc: nil).#{method}(*#{args})")
      end

      return eval("self[0].#{method}(*#{args})")
    end
  end

  def initialize(url = nil, doc: nil, html: nil, user_agent: nil, request_headers: nil, timeout: 10)
    ## -----*----- コンストラクタ -----*----- ##
    @agent = Mechanize.new
    @agent.keep_alive = false
    @agent.user_agent = user_agent  unless user_agent.nil?
    @agent.request_headers = request_headers  unless request_headers.nil?
    @agent.read_timeout = timeout

    if !url.nil?
      get(url)
    elsif !doc.nil?
      @html = doc.to_html
      @doc = doc
      table_to_hash
    else
      update_params(html)
      @html = html
    end

    @params = []
  end

  def get(url)
    ## -----*----- ページ推移 -----*----- ##
    @url = url
    begin
      page = @agent.get(@url)
      @code = page.code
    rescue Mechanize::ResponseCodeError => e
      @code = e.page.body
    rescue Net::HTTP::Persistent::Error => e
      puts e
    end
    html = page.content.toutf8
    update_params(html)
  end

  def send(opts)
    ## -----*----- フォームデータ指定 -----*----- ##
    #
    # テキスト，数値など　  => value（String）を指定
    # チェックボックス　　  => check（Bool）を指定
    # ファイルアップロード  => file（String）を指定
    # ボタンクリック        => click(Bool)を指定
    @params << {}
    opts = opts.map { |k, v| [k.to_sym, v] }.to_h
    opts.each { |k, v| @params[-1][k.to_sym] = v }
  end

  def submit(opts)
    ## -----*----- フォーム送信 -----*----- ##
    # フォーム指定
    opts = opts.map { |k,v| [k.to_sym, v] }.to_h
    if opts.kind_of?(Integer)
      form = @agent.page.forms[opts]
    else
      form = @agent.page.form(**opts)
    end
    return if form.nil?
    button = nil

    @params.each do |param|
      # テキスト，数値など
      if param.include?(:value) && !param.include?(:check)
        value = param.delete(:value)
        next if value.nil?
        form.field_with(**param).value = value unless form.field_with(**param).nil?
      end

      # チェックボックス
      if param.include?(:check)
        check = param.delete(:check)
        next if check.nil?
        if check
          form.checkbox_with(**param).check unless form.checkbox_with(**param).nil?
        else
          form.checkbox_with(**param).uncheck unless form.checkbox_with(**param).nil?
        end
      end

      # ファイルアップロード
      if param.include?(:file)
        file = param.delete(:file)
        next if file.nil? || !File.exist?(file)
        form.file_upload_with(**param).file_name = file unless form.file_upload_with(**param).nil?
      end

      # ボタンクリック
      if param.include?(:click)
        click = param.delete(:click)
        next unless click
        button = form.button_with(**param) unless form.button_with(**param).nil?
      end
    end

    form = @agent.submit(form, button)
    update_params(form.content.toutf8)
    @params = []
  end

  def xpath(locator, single = false)
    ## -----*----- HTMLからXPath指定で要素取得 -----*----- ##
    elements = CrawlArray.new(@doc.xpath(locator).map {|el| Husc.new(doc: el)})
    if single
      # シングルノード
      if elements[0] == nil
        return CrawlArray.new()
      else
        return elements[0]
      end
    else
      # 複数ノード
      return elements
    end
  end

  def css(locator, single = false)
    ## -----*----- HTMLからCSSセレクタで要素取得 -----*----- ##
    elements = CrawlArray.new(@doc.css(locator).map {|el| Husc.new(doc: el)})
    if single
      # シングルノード
      if elements[0] == nil
        return CrawlArray.new()
      else
        return elements[0]
      end
    else
      # 複数ノード
      return elements
    end
  end

  def inner_text(shaping = true)
    ## -----*----- タグ内の文字列を取得 -----*----- ##
    if shaping
      return shaping_string(@doc.inner_text)
    else
      @doc.inner_text
    end
  end

  def inner_html(shaping = true)
    ## -----*----- タグ内のHTMLを取得 -----*----- ##
    if shaping
      return shaping_string(@doc.inner_html)
    else
      @doc.inner_html
    end
  end

  def text(shaping = true)
    ## -----*----- タグ内の文字列（その他タグ除去）を取得 -----*----- ##
    if shaping
      return shaping_string(@doc.text)
    else
      @doc.text
    end
  end

  def attr(name)
    ## -----*----- ノードの属性情報取得 -----*----- ##
    ret = @doc.attr(name)
    if ret.nil?
      return ''
    else
      return ret
    end
  end


  private


  def update_params(html)
    ## -----*----- パラメータを更新 -----*----- ##
    @url = @agent.page.uri
    @html = html
    @doc = Nokogiri::HTML.parse(@html)
    table_to_hash
  end

  def table_to_hash
    ## -----*----- テーブル内容をHashに変換 -----*----- ##
    @tables = {}
    @doc.css('tr').each do |tr|
      @tables[tr.css('th').inner_text.gsub("\n", "").gsub(" ", "")] = shaping_string(tr.css('td').inner_text)
    end
    @doc.css('dl').each do |el|
      @tables[el.css('dt').inner_text.gsub("\n", "").gsub(" ", "")] = shaping_string(el.css('dd').inner_text)
    end
  end

  def shaping_string(str)
    ## -----*----- 文字例の整形 -----*----- ##
    # 余計な改行，空白を全て削除
    str = str.to_s
    return str.gsub(" ", ' ').squeeze(' ').gsub("\n \n", "\n").gsub("\n ", "\n").gsub("\r", "\n").squeeze("\n").gsub("\t", "").strip
  end
end

