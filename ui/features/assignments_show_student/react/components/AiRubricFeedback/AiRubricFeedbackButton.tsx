/*
 * Copyright (C) 2026 - present Instructure, Inc.
 *
 * This file is part of Canvas.
 */

import {useState} from 'react'
import {Button} from '@instructure/ui-buttons'
import {Modal} from '@instructure/ui-modal'
import {Heading} from '@instructure/ui-heading'
import {TextArea} from '@instructure/ui-text-area'
import {Text} from '@instructure/ui-text'
import {View} from '@instructure/ui-view'
import {Spinner} from '@instructure/ui-spinner'
import {List} from '@instructure/ui-list'
import {useScope as createI18nScope} from '@canvas/i18n'
import doFetchApi from '@canvas/do-fetch-api-effect'

const I18n = createI18nScope('assignments_2_student_ai_rubric_feedback')

type CriterionFeedback = {
  criterion?: string
  status?: string
  suggestion?: string
}

type FeedbackResponse = {
  feedback?: {
    weak_areas?: string[]
    suggestions?: string[]
    criteria?: CriterionFeedback[]
  }
}

type AiRubricFeedbackButtonProps = {
  isEnabled: boolean
}

export const AiRubricFeedbackButton = ({isEnabled}: AiRubricFeedbackButtonProps) => {
  const [isOpen, setIsOpen] = useState(false)
  const [draftText, setDraftText] = useState('')
  const [isLoading, setIsLoading] = useState(false)
  const [errorMessage, setErrorMessage] = useState<string | null>(null)
  const [weakAreas, setWeakAreas] = useState<string[]>([])
  const [suggestions, setSuggestions] = useState<string[]>([])
  const [criteriaFeedback, setCriteriaFeedback] = useState<CriterionFeedback[]>([])

  const resetFeedback = () => {
    setErrorMessage(null)
    setWeakAreas([])
    setSuggestions([])
    setCriteriaFeedback([])
  }

  const handleClose = () => {
    setIsOpen(false)
    resetFeedback()
  }

  const handleRequestFeedback = async () => {
    setIsLoading(true)
    resetFeedback()
    try {
      const {json} = await doFetchApi<FeedbackResponse>({
        method: 'POST',
        path: `/courses/${ENV.COURSE_ID}/assignments/${ENV.ASSIGNMENT_ID}/ai_rubric_feedback`,
        body: {draft_text: draftText},
        headers: {'Content-Type': 'application/json'},
      })
      const feedback = json?.feedback
      setWeakAreas(feedback?.weak_areas ?? [])
      setSuggestions(feedback?.suggestions ?? [])
      setCriteriaFeedback(feedback?.criteria ?? [])
    } catch {
      setErrorMessage(I18n.t('Could not load feedback. Please try again.'))
    } finally {
      setIsLoading(false)
    }
  }

  const hasFeedback =
    weakAreas.length > 0 || suggestions.length > 0 || criteriaFeedback.length > 0

  return (
    <>
      <Button
        id="ai-rubric-feedback-button"
        data-testid="ai-rubric-feedback-button"
        disabled={!isEnabled}
        color="secondary"
        withBackground={false}
        onClick={() => setIsOpen(true)}
      >
        {I18n.t('Get AI Feedback')}
      </Button>
      <Modal open={isOpen} onDismiss={handleClose} label={I18n.t('Get AI Feedback')} size="medium">
        <Modal.Header>
          <Heading level="h2">{I18n.t('Get AI Feedback')}</Heading>
        </Modal.Header>
        <Modal.Body>
          <View as="div" margin="small 0">
            <Text>
              {I18n.t(
                'Paste your draft below. Feedback is advisory only and does not affect your grade or submission.',
              )}
            </Text>
          </View>
          <TextArea
            label={I18n.t('Draft text')}
            value={draftText}
            onChange={(_e, value) => setDraftText(value)}
            height="10rem"
          />
          {isLoading && (
            <View as="div" margin="small 0" textAlign="center">
              <Spinner renderTitle={I18n.t('Loading feedback')} />
            </View>
          )}
          {errorMessage && (
            <View as="div" margin="small 0">
              <Text color="danger">{errorMessage}</Text>
            </View>
          )}
          {hasFeedback && !isLoading && (
            <View as="div" margin="medium 0 0 0">
              {criteriaFeedback.length > 0 ? (
                <>
                  <Text weight="bold">{I18n.t('Rubric feedback')}</Text>
                  <List isUnstyled margin="small 0">
                    {criteriaFeedback.map((row, index) => (
                      <List.Item key={`${row.criterion}-${index}`}>
                        <Text weight="bold">
                          {row.criterion}
                          {row.status === 'ok' ? ` (${I18n.t('looks good')})` : ''}
                        </Text>
                        {row.suggestion && <Text>{row.suggestion}</Text>}
                      </List.Item>
                    ))}
                  </List>
                </>
              ) : (
                <>
                  {weakAreas.length > 0 && (
                    <View as="div" margin="small 0">
                      <Text weight="bold">{I18n.t('Areas to strengthen')}</Text>
                      <List isUnstyled margin="x-small 0">
                        {weakAreas.map(area => (
                          <List.Item key={area}>
                            <Text>{area}</Text>
                          </List.Item>
                        ))}
                      </List>
                    </View>
                  )}
                  {suggestions.length > 0 && (
                    <View as="div" margin="small 0">
                      <Text weight="bold">{I18n.t('Suggestions')}</Text>
                      <List isUnstyled margin="x-small 0">
                        {suggestions.map((suggestion, index) => (
                          <List.Item key={`${index}-${suggestion}`}>
                            <Text>{suggestion}</Text>
                          </List.Item>
                        ))}
                      </List>
                    </View>
                  )}
                </>
              )}
              {weakAreas.length === 0 &&
                suggestions.length === 0 &&
                criteriaFeedback.every(c => c.status === 'ok') && (
                  <Text>{I18n.t('Your draft meets the rubric checks we can run locally.')}</Text>
                )}
            </View>
          )}
        </Modal.Body>
        <Modal.Footer>
          <Button onClick={handleClose}>{I18n.t('Close')}</Button>
          <Button color="primary" onClick={handleRequestFeedback} disabled={isLoading || !draftText.trim()}>
            {I18n.t('Request feedback')}
          </Button>
        </Modal.Footer>
      </Modal>
    </>
  )
}
