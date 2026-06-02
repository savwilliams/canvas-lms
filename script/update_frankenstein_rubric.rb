# frozen_string_literal: true

# Updates Essay 1 rubric: one metric per criterion, single essay prompt.
# Run: docker compose exec -T web bundle exec rails runner script/update_frankenstein_rubric.rb

course = Course.find(1)
assignment = course.assignments.find(1)
rubric = course.rubrics.find_by(title: "Frankenstein Essay Rubric") || assignment.rubric_association.rubric
raise "Rubric not found" unless rubric

# Each criterion measures exactly one thing. Ratings explain that metric only.
frankenstein_rubric_data = [
  {
    description: "Word count (minimum 500)",
    long_description: "Count: essay body is at least 500 words.",
    points: 20,
    id: "word_count",
    ratings: [
      { description: "20 pts — 500+ words", points: 20, id: "wc_ex", criterion_id: "word_count" },
      { description: "14 pts — 450–499 words", points: 14, id: "wc_prof", criterion_id: "word_count" },
      { description: "8 pts — 400–449 words", points: 8, id: "wc_dev", criterion_id: "word_count" },
      { description: "0 pts — under 400 words", points: 0, id: "wc_ins", criterion_id: "word_count" }
    ]
  },
  {
    description: "Thesis in introduction",
    long_description: "Count: one clear, debatable thesis sentence appears in the introduction.",
    points: 20,
    id: "thesis",
    ratings: [
      { description: "20 pts — debatable thesis in intro", points: 20, id: "th_ex", criterion_id: "thesis" },
      { description: "14 pts — thesis present but vague", points: 14, id: "th_prof", criterion_id: "thesis" },
      { description: "8 pts — topic only, no arguable claim", points: 8, id: "th_dev", criterion_id: "thesis" },
      { description: "0 pts — no thesis in intro", points: 0, id: "th_ins", criterion_id: "thesis" }
    ]
  },
  {
    description: "Direct quotations from Frankenstein",
    long_description: "Count: number of direct quotations from the novel.",
    points: 20,
    id: "quotes",
    ratings: [
      { description: "20 pts — 3 or more direct quotes", points: 20, id: "qu_ex", criterion_id: "quotes" },
      { description: "14 pts — exactly 2 direct quotes", points: 14, id: "qu_prof", criterion_id: "quotes" },
      { description: "8 pts — exactly 1 direct quote", points: 8, id: "qu_dev", criterion_id: "quotes" },
      { description: "0 pts — no direct quotes", points: 0, id: "qu_ins", criterion_id: "quotes" }
    ]
  },
  {
    description: "Body paragraph count",
    long_description: "Count: number of body paragraphs between introduction and conclusion.",
    points: 15,
    id: "body_paras",
    ratings: [
      { description: "15 pts — 4 or more body paragraphs", points: 15, id: "bp_ex", criterion_id: "body_paras" },
      { description: "11 pts — exactly 3 body paragraphs", points: 11, id: "bp_prof", criterion_id: "body_paras" },
      { description: "6 pts — exactly 2 body paragraphs", points: 6, id: "bp_dev", criterion_id: "body_paras" },
      { description: "0 pts — 0–1 body paragraphs", points: 0, id: "bp_ins", criterion_id: "body_paras" }
    ]
  },
  {
    description: "Analysis sentences (not plot summary)",
    long_description: "Count: body sentences that interpret meaning (not plot retell).",
    points: 15,
    id: "analysis",
    ratings: [
      { description: "15 pts — 80%+ of body sentences analyze", points: 15, id: "an_ex", criterion_id: "analysis" },
      { description: "11 pts — 60–79% analyze", points: 11, id: "an_prof", criterion_id: "analysis" },
      { description: "6 pts — 40–59% analyze", points: 6, id: "an_dev", criterion_id: "analysis" },
      { description: "0 pts — under 40% analyze", points: 0, id: "an_ins", criterion_id: "analysis" }
    ]
  },
  {
    description: "MLA in-text citations",
    long_description: "Count: MLA in-text citations to Frankenstein in the essay.",
    points: 10,
    id: "mla_intext",
    ratings: [
      { description: "10 pts — 3 or more in-text citations", points: 10, id: "mla_ex", criterion_id: "mla_intext" },
      { description: "7 pts — exactly 2 in-text citations", points: 7, id: "mla_prof", criterion_id: "mla_intext" },
      { description: "4 pts — exactly 1 in-text citation", points: 4, id: "mla_dev", criterion_id: "mla_intext" },
      { description: "0 pts — no in-text citations", points: 0, id: "mla_ins", criterion_id: "mla_intext" }
    ]
  }
]

assignment_description = <<~HTML
  <h2>Frankenstein Literary Analysis (at least 500 words)</h2>
  <p>Write an essay of <strong>at least 500 words</strong> (body text only; Works Cited does not count). Submit using the <strong>Text Entry</strong> box on this page.</p>
  <h3>Topic</h3>
  <p><strong>How does Mary Shelley use Victor Frankenstein and the Creature to explore responsibility for scientific creation?</strong> Take a clear position in your thesis and support it with evidence from the novel.</p>
  <h3>Checklist before you submit</h3>
  <ul>
    <li>500+ words in the essay body</li>
    <li>One debatable thesis in the introduction</li>
    <li>At least two direct quotations from <em>Frankenstein</em></li>
    <li>At least three body paragraphs plus introduction and conclusion</li>
    <li>Most body sentences analyze (do not retell the plot)</li>
    <li>At least two MLA in-text citations and a Works Cited entry for the novel</li>
  </ul>
HTML

course.enable_feature!(:assignments_2_student)
course.enable_feature!(:ai_rubric_feedback)

rubric.update!(data: frankenstein_rubric_data, points_possible: 100)
assignment.update!(description: assignment_description)

puts "Updated rubric #{rubric.id} and assignment #{assignment.id}"
rubric.data.each { |c| puts "  #{c[:description]} — #{c[:long_description]}" }
