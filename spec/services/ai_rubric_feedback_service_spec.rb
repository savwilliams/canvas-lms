# frozen_string_literal: true

#
# Copyright (C) 2026 - present Instructure, Inc.
#
# This file is part of Canvas.
#

describe AiRubricFeedbackService do
  let_once(:course) { Course.create! }
  let_once(:teacher) { User.create! }
  let_once(:assignment) do
    course.assignments.create!(title: "Essay", submission_types: "online_text_entry")
  end
  let(:rubric_data) do
    [
      {
        description: "Word count (minimum 500)",
        long_description: "Count: essay body is at least 500 words.",
        points: 20,
        id: "word_count",
        ratings: [{ description: "Full", points: 20, id: "wc_ex", criterion_id: "word_count" }],
      },
      {
        description: "Thesis in introduction",
        long_description: "Count: one clear, debatable thesis sentence appears in the introduction.",
        points: 20,
        id: "thesis",
        ratings: [{ description: "Full", points: 20, id: "th_ex", criterion_id: "thesis" }],
      },
      {
        description: "Direct quotations from Frankenstein",
        long_description: "Count: number of direct quotations from the novel.",
        points: 20,
        id: "quotes",
        ratings: [{ description: "Full", points: 20, id: "qu_ex", criterion_id: "quotes" }],
      },
    ]
  end

  before :once do
    course.enroll_user(teacher, "TeacherEnrollment", enrollment_state: "active")
    rubric = course.rubrics.create!(title: "Essay Rubric", user: teacher, data: rubric_data, points_possible: 60)
    rubric_association_params = ActiveSupport::HashWithIndifferentAccess.new(
      hide_score_total: "0",
      purpose: "grading",
      skip_updating_points_possible: false,
      update_if_existing: true,
      use_for_grading: "1",
      association_object: assignment
    )
    assignment.rubric_association = RubricAssociation.generate(teacher, rubric, course, rubric_association_params)
    assignment.save!
  end

  describe ".call" do
    it "flags weak rubric areas for a short draft" do
      draft = "Frankenstein is a book about a monster. Victor creates life."
      result = described_class.call(assignment:, draft_text: draft)

      expect(result[:feedback][:weak_areas]).to include("Word count (minimum 500)")
      expect(result[:feedback][:suggestions]).to be_present
      expect(result[:feedback][:criteria].length).to eq 3
      expect(result[:feedback][:criteria].pluck(:status)).to include("weak")
    end

    it "returns mostly ok criteria for a stronger draft" do
      intro = "Shelley argues that creators must accept responsibility because Victor abandons his creation."
      body = ("Analysis shows Victor's guilt grows. " * 80) + '"I ought to be thy Adam" (Shelley 103). '
      body += ("The Creature's plea demands ethical duty. " * 80) + '"Remember that I am thy creature" (Shelley 104).'
      conclusion = "Therefore scientific creation requires moral accountability."
      draft = [intro, body, body, body, conclusion].join("\n\n")

      result = described_class.call(assignment:, draft_text: draft)
      weak_count = result[:feedback][:criteria].count { |c| c[:status] == "weak" }

      expect(weak_count).to be < 3
    end

    it "raises when draft exceeds max length" do
      expect do
        described_class.call(assignment:, draft_text: "word " * 60_000)
      end.to raise_error(AiRubricFeedbackService::DraftTooLong)
    end
  end
end
