# frozen_string_literal: true

#
# Copyright (C) 2026 - present Instructure, Inc.
#
# This file is part of Canvas.
#

# Rubric-aligned advisory feedback for student drafts (MVP slice 2).
# Uses deterministic heuristics keyed off rubric criterion text — no grade writes,
# no external LLM required. Replace or augment with an LLM provider in a later slice.
class AiRubricFeedbackService < ApplicationService
  class DraftTooLong < StandardError; end

  MAX_DRAFT_CHARS = 50_000
  ANALYSIS_WORDS = %w[
    because therefore however although demonstrates suggests implies symbolizes
    reveals argues conveys emphasizes critiques interprets
  ].freeze
  PLOT_SUMMARY_WORDS = %w[
    then next afterwards finally victor creature monster frankenstein
    chapter scene happens died killed created
  ].freeze

  def initialize(assignment:, draft_text:)
    @assignment = assignment
    @draft_text = draft_text.to_s.strip
    @rubric = assignment.rubric
  end

  def call
    raise DraftTooLong if @draft_text.length > MAX_DRAFT_CHARS

    criteria_list = Array(@rubric.data)
    criteria_results = criteria_list.map { |criterion| evaluate_criterion(criterion) }
    weak = criteria_results.select { |r| r[:status] == "weak" }

    {
      feedback: {
        weak_areas: weak.pluck(:criterion),
        suggestions: weak.pluck(:suggestion),
        criteria: criteria_results,
      },
    }
  end

  private

  def evaluate_criterion(criterion)
    criterion = criterion.with_indifferent_access
    label = criterion[:description].presence || "Criterion"
    kind = criterion_kind(criterion)
    send(:"check_#{kind}", criterion, label).merge(criterion: label)
  end

  def criterion_kind(criterion)
    text = [criterion[:description], criterion[:long_description]].compact.join(" ")
    case text
    when /word count|minimum.*\d+.*word|\d+\+?\s*words/i then :word_count
    when /thesis/i then :thesis
    when /quotation|quotes/i then :quotes
    when /paragraph/i then :paragraphs
    when /analysis|plot summary/i then :analysis
    when /mla|citation/i then :mla
    else :generic
    end
  end

  def check_word_count(criterion, label)
    target = extract_minimum_words(criterion) || 500
    count = word_count
    if count >= target
      ok(label, "About #{count} words — meets the #{target}-word minimum.")
    else
      weak(label, "Add about #{target - count} more words (currently ~#{count}; minimum #{target}).")
    end
  end

  def check_thesis(_criterion, label)
    intro = paragraphs.first.to_s
    if intro.match?(/\b(argue|claims?|demonstrates|because|although|thesis)\b/i) && intro.length > 40
      ok(label, "Introduction appears to state an arguable position.")
    else
      weak(label, "Add one clear, debatable thesis sentence in the introduction.")
    end
  end

  def check_quotes(_criterion, label)
    count = direct_quote_count
    if count >= 2
      ok(label, "Includes #{count} direct quotation(s) from the text.")
    else
      weak(label, "Add #{2 - count} more direct quotation(s) from the novel (use quotation marks).")
    end
  end

  def check_paragraphs(_criterion, label)
    body_count = [paragraphs.length - 2, 0].max
    if body_count >= 3
      ok(label, "About #{body_count} body paragraph(s) detected.")
    else
      weak(label, "Add #{3 - body_count} more body paragraph(s) between introduction and conclusion.")
    end
  end

  def check_analysis(_criterion, label)
    ratio = analysis_ratio
    if ratio >= 0.6
      ok(label, "Most body sentences look interpretive rather than plot summary.")
    else
      weak(label, "Rewrite more body sentences to explain meaning (why/how), not retell plot events.")
    end
  end

  def check_mla(_criterion, label)
    count = mla_citation_count
    if count >= 2
      ok(label, "Includes #{count} parenthetical citation(s).")
    else
      weak(label, "Add #{2 - count} more MLA in-text citation(s), e.g. (Shelley 42).")
    end
  end

  def check_generic(_criterion, label)
    if @draft_text.length < 100
      weak(label, "Expand your draft before requesting feedback on this criterion.")
    else
      ok(label, "Draft present — review this criterion against the rubric ratings.")
    end
  end

  def ok(_label, message)
    { status: "ok", suggestion: message }
  end

  def weak(_label, message)
    { status: "weak", suggestion: message }
  end

  def extract_minimum_words(criterion)
    text = [criterion[:description], criterion[:long_description]].join(" ")
    if (m = text.match(/minimum\s+(\d+)|(\d+)\+?\s*words/i))
      (m[1] || m[2]).to_i
    end
  end

  def word_count
    @draft_text.split(/\s+/).count { |w| w.present? }
  end

  def paragraphs
    @paragraphs ||= @draft_text.split(/\n\s*\n/).map(&:strip).reject(&:blank?)
  end

  def direct_quote_count
    @draft_text.scan(/"[^"\n]{5,}"/).size +
      @draft_text.scan(/“[^”\n]{5,}”/).size
  end

  def mla_citation_count
    @draft_text.scan(/\([A-Za-z][\w\s.&-]+ \d+\)/).size
  end

  def analysis_ratio
    body = paragraphs.length > 2 ? paragraphs[1..-2].join(" ") : @draft_text
    sentences = body.split(/[.!?]+/).map(&:strip).reject(&:blank?)
    return 1.0 if sentences.empty?

    analysis_sentence_count = sentences.count do |sentence|
      words = sentence.downcase.split(/\W+/)
      analysis_hits = (words & ANALYSIS_WORDS).size
      plot_hits = (words & PLOT_SUMMARY_WORDS).size
      analysis_hits >= 1 && analysis_hits >= plot_hits
    end
    analysis_sentence_count.to_f / sentences.length
  end
end
