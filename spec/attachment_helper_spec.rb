require 'spec_helper'


RSpec.describe Paperclip::Globalize3::Attachment do

  before(:each) do
    stub_const('Rails', double('Rails'))
    allow(Rails).to receive(:root).and_return(ROOT.join('tmp'))
    allow(Rails).to receive(:env).and_return('test')
    allow(Rails).to receive(:const_defined?).with(:Railtie).and_return(false)
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
        expect(p.image_file_name).to be_nil
        p.update_attributes!(:image => test_image_file)
        expect(p.image_file_name).to eq("test.png")
      end
      expect(Post.count).to eq(1)
      expect(Post.translation_class.count).to eq(1)

      Globalize.with_locale(:de) do
        expect(p.image_file_name).to be_nil
        p.update_attributes!(:image => test_image_file2)
        expect(p.image_file_name).to eq("test2.png")
      end
      Globalize.with_locale(:en) do
        expect(p.image_file_name).to eq("test.png")
      end
      expect(Post.count).to eq(1)
      expect(Post.translation_class.count).to eq(2)
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
      expect(File.exist?(path_en)).to be_truthy
      expect(File.exist?(path_de)).to be_truthy

      # re-assign 'en' image (use different image)
      path_en2 = Globalize.with_locale(:en) do
        p.update_attributes!(:image => test_image_file2)
        p.image.path
      end
      expect([path_en, path_en2, path_de].uniq.size).to eq(3) # paths should all be different
      expect(File.exist?(path_en)).to be_falsey
      expect(File.exist?(path_en2)).to be_truthy
      expect(File.exist?(path_de)).to be_truthy
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
      expect(File.exist?(path_en)).to be_truthy
      expect(File.exist?(path_de)).to be_truthy

      p.destroy
      expect(File.exist?(path_en)).to be_falsey
      expect(File.exist?(path_de)).to be_falsey
    end

    context 'with :only_process' do

      it 'only clears the provided style in the current locale on assign' do
        p = OnlyProcessPost.create
        expect(p.image).to receive(:queue_some_for_delete).with(:thumb, :locales => :en)
        expect(p.image).not_to receive(:queue_all_for_delete)

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
      expect(File.exist?(path)).to be_truthy

      p.destroy
      expect(File.exist?(path)).to be_falsey
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

      Globalize.with_locale(:en) { expect(File.exists?(p.image.path)).to be_truthy }
      Globalize.with_locale(:de) { expect(File.exists?(p.image.path)).to be_truthy }
    end
  end

end
