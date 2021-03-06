# encoding: UTF-8

# Copyright 2012 Twitter, Inc
# http://www.apache.org/licenses/LICENSE-2.0

require 'spec_helper'

include TwitterCldr::Localized

describe LocalizedSymbol do

  describe "#as_language_code" do
    it "returns the correct localized language from the symbol" do
      :es.localize.as_language_code.should == "Spanish"
      TwitterCldr.locale = :es
      :es.localize.as_language_code.should == "español"
    end

    it "returns nil if the symbol doesn't correspond to a language code" do
      :blarg.localize.as_language_code.should == nil
    end

    it "returns the correct value for mapped as well as CLDR language codes" do
      :'zh-cn'.localize.as_language_code.should == "Chinese"
      :'zh-tw'.localize.as_language_code.should == "Traditional Chinese"
      :'zh-Hant'.localize.as_language_code.should == "Traditional Chinese"
      :'zh'.localize.as_language_code.should == "Chinese"
    end
  end

  describe "#is_rtl?" do
    it "should return true or false depending on the locale" do
      :es.localize.is_rtl?.should be_false
      :ar.localize.is_rtl?.should be_true
    end
  end

end