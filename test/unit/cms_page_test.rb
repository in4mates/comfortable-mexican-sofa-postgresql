require File.dirname(__FILE__) + '/../test_helper'

class CmsPageTest < ActiveSupport::TestCase
  
  def test_render
    page = cms_pages(:default)
    assert_equal [
      'default_page_text_content',
      'default_page_string_content',
      '1'
    ].join("\n"), page.content
  end
  
  def test_blocks_initialization
    page = cms_pages(:default)
    page.initialize_tags
  end
  
end
