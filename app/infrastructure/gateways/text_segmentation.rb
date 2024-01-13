# frozen_string_literal: true

require 'punkt-segmenter'

module TranSound
  module Podcast
    module SegmentingUtils
      # Object for text segmentation by punkt-segmenter
      class TextSegmentation
        def initialize(text)
          @text = text
        end

        def segment
          # 移除 "LAUGHTER" 和 "MUSIC"
          text_without_laughter_music = @text.gsub(/LAUGHTER|MUSIC|/, '')
          # 初始化 Punkt::SentenceTokenizer
          tokenizer = Punkt::SentenceTokenizer.new(text_without_laughter_music)
          # 取得斷句結果
          tokenizer.sentences_from_text(text_without_laughter_music, output: :sentences_text)
        end
      end
    end
  end
end

# test
# text = "MUSIC I've got a big family, cos I had older brothers and sisters, and they all had loads of kids, and their kids have had loads of kids, and their kids have had loads of kids, cos we're chavs, basically. There's a new baby every Christmas. It's one of those families. I go home, it's crowded. I go, oh, oh, who's this? Oh, yours? Oh, well done. I don't know him, I don't know her. You know what I mean? It's like... But what I've done over the last couple of years, I've got them each individually, right, in private, and I've told them that I'm leaving my entire fortune to just them, right? But to keep it secret. So they all love me, right? And I'm not doing a will, so my funeral is going to be a fucking bloodbath. LAUGHTER"
# text = "I've got a big family, cos I had older brothers and sisters, and they all had loads of kids, and their kids have had loads of kids, and their kids have had loads of kids, cos we're chavs, basically.
#           There's a new baby every Christmas.
#           It's one of those families.
#           I go home, it's crowded.
#           I go, oh, oh, who's this?
#           Oh, yours?
#           Oh, well done.
#           I don't know him, I don't know her.
#           You know what I mean?
#           It's like... But what I've done over the last couple of years, I've got them each individually, right, in private, and I've told them that I'm leaving my entire fortune to just them, right?
#           But to keep it secret.
#           So they all love me, right?
#           And I'm not doing a will, so my funeral is going to be a fucking bloodbath."
# sentence_seg = TranSound::Podcast::SegmentingUtils::TextSegmentation.new(text).segment
# puts "sentence_segmentation:\n#{sentence_seg}"
# puts sentence_seg.length
