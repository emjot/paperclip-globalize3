require 'spec_helper'


describe 'Paperclip::Globalize3::Attachment' do

  before(:each) do
    stub_const('Rails', double('Rails'))
    Rails.stub(:root).and_return(ROOT.join('tmp'))
    Rails.stub(:env).and_return('test')
    Rails.stub(:const_defined?).with(:Railtie).and_return(false)
  end

  let (:test_image_dir) do
    File.expand_path(File.join(File.dirname(__FILE__), 'data'))
  end

  let(:test_image_file) do
    File.new(File.join(test_image_dir,'test.png'))
  end

  let(:test_image_file2) do
    File.new(File.join(test_image_dir, 'test2.png'))
  end

  context 'with translations' do

    it 'saves different images for different locales' do
      p = Post.create
      Globalize.with_locale(:en) do
        p.image_file_name.should be_nil
        p.update_attributes!(:image => test_image_file)
        p.image_file_name.should == "test.png"
      end
      Post.count.should == 1
      Post.translation_class.count.should == 1

      Globalize.with_locale(:de) do
        p.image_file_name.should be_nil
        p.update_attributes!(:image => test_image_file2)
        p.image_file_name.should == "test2.png"
      end
      Globalize.with_locale(:en) do
        p.image_file_name.should == "test.png"
      end
      Post.count.should == 1
      Post.translation_class.count.should == 2
    end

    it 'only overwrites the image file for the current locale on re-assign' do
      p = Post.create
      path_en = Globalize.with_locale(:en) do
        p.update_attributes!(:image => test_image_file)
        p.image.path
      end
      path_de = Globalize.with_locale(:de) do
        p.update_attributes!(:image => test_image_file2)
        p.image.path
      end
      File.exist?(path_en).should be_true
      File.exist?(path_de).should be_true

      # re-assign 'en' image (use different image)
      path_en2 = Globalize.with_locale(:en) do
        p.update_attributes!(:image => test_image_file2)
        p.image.path
      end
      [path_en, path_en2, path_de].uniq.size.should == 3 # paths should all be different
      File.exist?(path_en).should be_false
      File.exist?(path_en2).should be_true
      File.exist?(path_de).should be_true
    end

    it 'deletes image files in all locales on destroy' do
      p = Post.create
      path_en = Globalize.with_locale(:en) do
        p.update_attributes!(:image => test_image_file)
        p.image.path
      end
      path_de = Globalize.with_locale(:de) do
        p.update_attributes!(:image => test_image_file)
        p.image.path
      end
      File.exist?(path_en).should be_true
      File.exist?(path_de).should be_true

      p.destroy
      File.exist?(path_en).should be_false
      File.exist?(path_de).should be_false
    end

    context 'with :only_process' do

      it 'only clears the provided style in the current locale on assign' do
        p = OnlyProcessPost.create
        p.image.should_receive(:queue_some_for_delete).with(:thumb, :locales => :en)
        p.image.should_not_receive(:queue_all_for_delete)

        Globalize.with_locale(:en) do
          p.update_attributes!(:image => test_image_file)
        end
      end

    end

  end

  context 'without translations' do

    it 'deletes image files on destroy' do
      p = Untranslated.create
      p.update_attributes!(:image => test_image_file)
      path = p.image.path
      File.exist?(path).should be_true

      p.destroy
      File.exist?(path).should be_false
    end

  end

  context 'with fallbacks' do
    around :each do |example|
      old_fallbacks = Globalize.fallbacks
      Globalize.fallbacks = {en: [:en, :de], de: [:de, :en]}
      example.run
      Globalize.fallbacks = old_fallbacks
    end

    it 'interpolates the correct locale if fallback is used' do
      p = nil
      Globalize.with_locale(:en) { p = Post.new( image: test_image_file); p.save! }
      Globalize.with_locale(:de) { expect(p.image.url).to match('/en/') }
    end

    it 'preserves attachments when a new translation is created' do
      p = nil
      Globalize.with_locale(:de) do
        p = Post.new(image: test_image_file)
        p.save!
      end
      Globalize.with_locale(:en) do
        p.image          = test_image_file
        p.save!
      end

      Globalize.with_locale(:en) { expect(File.exists?(p.image.path)).to be_true }
      Globalize.with_locale(:de) { expect(File.exists?(p.image.path)).to be_true }
    end
  end

end