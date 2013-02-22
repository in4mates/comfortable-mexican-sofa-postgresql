class CreateCms < ActiveRecord::Migration
  
  def self.up
    
    text_limit = case ActiveRecord::Base.connection.adapter_name
      when 'PostgreSQL'
        { }
      else
        { :limit => 16777215 }
                 end


    create_schema 'cms'

    # -- Sites --------------------------------------------------------------
    create_table :cms_sites, :schema => "cms" do |t|
      t.string :label,        :null => false
      t.string :identifier,   :null => false
      t.string :hostname,     :null => false
      t.string :path
      t.string :locale,       :null => false, :default => 'en'
      t.boolean :is_mirrored, :null => false, :default => false
    end
    add_index 'cms.cms_sites', :hostname
    add_index 'cms.cms_sites', :is_mirrored
    
    # -- Layouts ------------------------------------------------------------
    create_table :cms_layouts, :schema => "cms" do |t|
      t.integer :site_id,     :null => false
      t.integer :parent_id
      t.string  :app_layout
      t.string  :label,       :null => false
      t.string  :identifier,  :null => false
      t.text    :content,     text_limit
      t.text    :css,         text_limit
      t.text    :js,          text_limit
      t.integer :position,    :null => false, :default => 0
      t.boolean :is_shared,   :null => false, :default => false
      t.timestamps
    end
    add_index 'cms.cms_layouts', [:parent_id, :position]
    add_index 'cms.cms_layouts', [:site_id, :identifier], :unique => true
    
    # -- Pages --------------------------------------------------------------
    create_table :cms_pages, :schema => "cms" do |t|
      t.integer :site_id,         :null => false
      t.integer :layout_id
      t.integer :parent_id
      t.integer :target_page_id
      t.string  :label,           :null => false
      t.string  :slug
      t.string  :full_path,       :null => false
      t.text    :content,         text_limit
      t.integer :position,        :null => false, :default => 0
      t.integer :children_count,  :null => false, :default => 0
      t.boolean :is_published,    :null => false, :default => true
      t.boolean :is_shared,       :null => false, :default => false
      t.timestamps
    end
    add_index 'cms.cms_pages', [:site_id, :full_path]
    add_index 'cms.cms_pages', [:parent_id, :position]
    
    # -- Page Blocks --------------------------------------------------------
    create_table :cms_blocks, :schema => "cms" do |t|
      t.integer   :page_id,     :null => false
      t.string    :identifier,  :null => false
      t.text      :content
      t.timestamps
    end
    add_index 'cms.cms_blocks', [:page_id, :identifier]
    
    # -- Snippets -----------------------------------------------------------
    create_table :cms_snippets, :schema => "cms" do |t|
      t.integer :site_id,     :null => false
      t.string  :label,       :null => false
      t.string  :identifier,  :null => false
      t.text    :content,     text_limit
      t.integer :position,    :null => false, :default => 0
      t.boolean :is_shared,   :null => false, :default => false
      t.timestamps
    end
    add_index 'cms.cms_snippets', [:site_id, :identifier], :unique => true
    add_index 'cms.cms_snippets', [:site_id, :position]
    
    # -- Files --------------------------------------------------------------
    create_table :cms_files, :schema => "cms" do |t|
      t.integer :site_id,           :null => false
      t.integer :block_id
      t.string  :label,             :null => false
      t.string  :file_file_name,    :null => false
      t.string  :file_content_type, :null => false
      t.integer :file_file_size,    :null => false
      t.string  :description,       :limit => 2048
      t.integer :position,          :null => false, :default => 0
      t.timestamps
    end
    add_index 'cms.cms_files', [:site_id, :label]
    add_index 'cms.cms_files', [:site_id, :file_file_name]
    add_index 'cms.cms_files', [:site_id, :position]
    add_index 'cms.cms_files', [:site_id, :block_id]
    
    # -- Revisions -----------------------------------------------------------
    create_table :cms_revisions, :schema => "cms", :force => true do |t|
      t.string    :record_type, :null => false
      t.integer   :record_id,   :null => false
      t.text      :data,        text_limit
      t.datetime  :created_at
    end
    add_index 'cms.cms_revisions', [:record_type, :record_id, :created_at],
      :name => 'index_cms_revisions_on_record_type_and_record_id_and_created_at'
    
    # -- Categories ---------------------------------------------------------
    create_table :cms_categories, :schema => "cms", :force => true do |t|
      t.integer :site_id,          :null => false
      t.string  :label,            :null => false
      t.string  :categorized_type, :null => false
    end
    add_index 'cms.cms_categories', [:site_id, :categorized_type, :label], :unique => true,
       :name => 'index_cms_categories_on_site_id_and_categorized_type_and_label'
    
    create_table :cms_categorizations, :schema => "cms", :force => true do |t|
      t.integer :category_id,       :null => false
      t.string  :categorized_type,  :null => false
      t.integer :categorized_id,    :null => false
    end
    add_index 'cms.cms_categorizations', [:category_id, :categorized_type, :categorized_id], :unique => true,
      :name => 'index_cms_categorizations_on_cat_id_and_catd_type_and_catd_id'
  end
  
  def self.down
    drop_table 'cms.cms_sites'
    drop_table 'cms.cms_layouts'
    drop_table 'cms.cms_pages'
    drop_table 'cms.cms_snippets'
    drop_table 'cms.cms_blocks'
    drop_table 'cms.cms_files'
    drop_table 'cms.cms_revisions'
    drop_table 'cms.cms_categories'
    drop_table 'cms.cms_categorizations'
  end
end

