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
import {useScope as createI18nScope} from '@canvas/i18n'
import doFetchApi from '@canvas/do-fetch-api-effect'

const I18n = createI18nScope('assignments_2_student_ai_rubric_feedback')

type AiRubricFeedbackButtonProps = {
  isEnabled: boolean
}

type FeedbackResponse = {
  feedback?: {
    weak_areas?: string[]
    suggestions?: string[]
  }
}

export const AiRubricFeedbackButton = ({isEnabled}: AiRubricFeedbackButtonProps) => {
  const [isOpen, setIsOpen] = useState(false)
  const [draftText, setDraftText] = useState('')
  const [isLoading, setIsLoading] = useState(false)
  const [errorMessage, setErrorMessage] = useState<string | null>(null)
  const [feedbackText, setFeedbackText] = useState<string | null>(null)

  const handleClose = () => {
    setIsOpen(false)
    setErrorMessage(null)
    setFeedbackText(null)
  }

  const handleRequestFeedback = async () => {
    setIsLoading(true)
    setErrorMessage(null)
    setFeedbackText(null)
    try {
      const {json} = await doFetchApi<FeedbackResponse>({
        method: 'POST',
        path: `/courses/${ENV.COURSE_ID}/assignments/${ENV.ASSIGNMENT_ID}/ai_rubric_feedback`,
        body: {draft_text: draftText},
        headers: {'Content-Type': 'application/json'},
      })
      const suggestions = json?.feedback?.suggestions ?? []
      const weakAreas = json?.feedback?.weak_areas ?? []
      const lines = [
        ...weakAreas.map(area => I18n.t('Weak area: %{area}', {area})),
        ...suggestions,
      ]
      setFeedbackText(lines.join('\n') || I18n.t('No feedback returned.'))
    } catch {
      setErrorMessage(I18n.t('Could not load feedback. Please try again.'))
    } finally {
      setIsLoading(false)
    }
  }

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
          {feedbackText && (
            <View as="div" margin="small 0">
              <Text weight="bold">{I18n.t('Feedback')}</Text>
              <Text as="pre">{feedbackText}</Text>
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
