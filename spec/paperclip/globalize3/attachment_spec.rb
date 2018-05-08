require 'spec_helper'

RSpec.describe Paperclip::Globalize3::Attachment do
  def with_locale(*args, &block)
    Globalize.with_locale(*args, &block)
  end

  def with_locales(*args, &block)
    Globalize.with_locales(*args, &block)
  end

  before do
    stub_const('Rails', double('Rails'))
    allow(Rails).to receive(:root).and_return(ROOT.join('tmp'))
    allow(Rails).to receive(:env).and_return('test')
    allow(Rails).to receive(:const_defined?).with(:Railtie).and_return(false)
  end

  let(:test_image_dir) do
    File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'data'))
  end

  let(:test_image_file) do
    File.new(File.join(test_image_dir, 'test.png'))
  end

  let(:test_image_file2) do
    File.new(File.join(test_image_dir, 'test2.png'))
  end

  let(:sample_post_with_en) do
    Post.create!.tap do |post|
      with_locale(:en) { post.update!(image: test_image_file) }
    end
  end

  let(:sample_post_with_en_and_de) do
    Post.create!.tap do |post|
      with_locale(:en) { post.update!(image: test_image_file) }
      with_locale(:de) { post.update!(image: test_image_file2) }
    end
  end

  describe 'attachment assignment' do
    context 'when attachment has been assigned in one locale' do
      let!(:post) { sample_post_with_en }

      it 'is present in that locale' do
        expect(with_locale(:en) { post.image_file_name }).to eq('test.png')
      end

      it 'exists in the file system in that locale' do
        expect(File).to be_exist(with_locale(:en) { post.image.path })
      end

      it 'is not present in another locale' do
        expect(with_locale(:de) { post.image_file_name }).to be_nil
      end

      it('results in a model count of 1') do
        expect(Post.count).to eq(1)
      end

      it('results in a model translations count of 1') do
        expect(Post.translation_class.count).to eq(1)
      end
    end

    context 'when assignment is done in multiple locales before saving' do
      let!(:post) do
        Post.new.tap do |p|
          with_locale(:en) { p.image = test_image_file }
          with_locale(:de) { p.image = test_image_file2 }
          p.save!
        end
      end

      it 'is present in fist locale' do
        expect(with_locale(:en) { post.image_file_name }).to eq('test.png')
      end

      it 'is present in second locale' do
        expect(with_locale(:de) { post.image_file_name }).to eq('test2.png')
      end

      it 'exists in the file system in the first locale' do
        expect(File).to be_exist(with_locale(:en) { post.image.path })
      end

      it 'exists in the file system in the second locale' do
        expect(File).to be_exist(with_locale(:de) { post.image.path })
      end

      it('results in a model count of 1') do
        expect(Post.count).to eq(1)
      end

      it('results in a model translations count of 2') do
        expect(Post.translation_class.count).to eq(2)
      end
    end

    context 'when another attachment gets assigned to a different locale' do
      subject(:assign_to_different) { with_locale(:de) { post.update!(image: test_image_file2) } }

      let!(:post) { sample_post_with_en }

      it 'is present in that different locale' do
        expect { assign_to_different }.to change { with_locale(:de) { post.image_file_name } }.
          from(nil).to('test2.png')
      end

      it 'has a different file path than in the first locale' do
        assign_to_different
        expect(with_locale(:de) { post.image.path }).not_to eq(with_locale(:en) { post.image.path })
      end

      it 'exists in the file system in that different locale' do
        assign_to_different
        expect(File).to be_exist((with_locale(:de) { post.image.path }))
      end

      it 'does not change the attachment in the first locale' do
        expect { assign_to_different }.not_to(change { with_locale(:en) { post.image_file_name } })
      end

      it 'does not delete the file in the first locale' do
        expect { assign_to_different }.not_to(change { File.exist?(with_locale(:en) { post.image.path }) })
      end

      it('does not change the model count') { expect { assign_to_different }.not_to change(Post, :count) }

      it 'changes the model translations count by 1' do
        expect { assign_to_different }.to change(Post.translation_class, :count).by(1)
      end
    end

    context 'when attachments have been assigned in multiple locales and one gets re-assigned' do
      subject(:re_assign_en) { with_locale(:en) { post.update!(image: test_image_file2) } }

      let!(:post)             { sample_post_with_en_and_de }
      let!(:original_path_en) { with_locale(:en) { post.image.path } }
      let!(:original_path_de) { with_locale(:de) { post.image.path } }

      it 'changes the path in that locale' do
        expect { re_assign_en }.to(change { with_locale(:en) { post.image.path } })
      end

      it 'deletes the old file in that locale' do
        expect { re_assign_en }.to change { File.exist?(original_path_en) }.from(true).to(false)
      end

      it 'creates the new file in that locale' do
        re_assign_en
        expect(File).to be_exist(with_locale(:en) { post.image.path })
      end

      it 'does not delete the files of the other locales' do
        re_assign_en
        expect(File).to be_exist(original_path_de)
      end
    end

    context 'when attachment defines :only_process' do
      subject(:assign) { with_locale(:en) { post.update!(image: test_image_file) } }

      let!(:post) { OnlyProcessPost.create }

      it 'only clears the provided style in the current locale' do
        expect(post.image).to receive(:queue_some_for_delete).with(:thumb, locales: :en)
        expect(post.image).not_to receive(:queue_all_for_delete)
        assign
      end
    end
  end

  describe 'model destroy' do
    subject(:destroy) { post.destroy }

    context 'when model has translations' do
      let!(:post)             { sample_post_with_en_and_de }
      let!(:original_path_en) { with_locale(:en) { post.image.path } }
      let!(:original_path_de) { with_locale(:de) { post.image.path } }

      it 'deletes all attachments in all locales' do
        expect { destroy }.
          to change { [File.exist?(original_path_en), File.exist?(original_path_de)] }.
          from([true, true]).
          to([false, false])
      end
    end

    context 'when model does not have translations' do
      let!(:post)           { Untranslated.create!(image: test_image_file) }
      let!(:original_path)  { post.image.path }

      it 'deletes attachment files' do
        expect { destroy }.to change { File.exist?(original_path) }.from(true).to(false)
      end
    end
  end

  context 'when fallbacks are defined' do
    around do |example|
      old_fallbacks = Globalize.fallbacks
      Globalize.fallbacks = {en: %i[en de], de: %i[de en]}
      example.run
      Globalize.fallbacks = old_fallbacks
    end

    describe 'reading the attachment url in a non-existent locale' do
      let!(:post) { sample_post_with_en }

      it 'returns the attachment url in the fallback locale' do
        with_locale(:de) { expect(post.image.url).to match('/en/') }
      end
    end

    describe 'attachment assignment' do
      context 'when another attachment gets assigned to a different locale' do
        subject(:assign_to_different) { with_locale(:de) { post.update!(image: test_image_file) } }

        let!(:post) { sample_post_with_en }

        it 'has files for all attachments in all locales' do
          assign_to_different
          expect(with_locales(:en, :de) { File.exist?(post.image.path) }).to be_all
        end
      end
    end
  end
end
