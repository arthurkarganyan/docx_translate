#!/usr/bin/env ruby

require "bundler/setup"
require 'docx'
require 'pry'
require 'ask_and_store'
require "google/cloud/translate"

require_relative '../lib/translator'
require_relative '../lib/document_translator'
require_relative '../lib/main'

Main.new.start
