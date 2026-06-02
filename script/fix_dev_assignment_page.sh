#!/usr/bin/env bash
# Fix blank A2 assignment page: flags, assets, restart web.
set -euo pipefail
cd "$(dirname "$0")/.."

echo "Enabling course feature flags..."
docker compose exec -T web bundle exec rails runner "
  c = Course.find(1)
  c.enable_feature!(:assignments_2_student)
  c.enable_feature!(:ai_rubric_feedback)
  a = Assignment.find(1)
  puts \"a2_enabled=#{a.a2_enabled?}\"
"

echo "Rebuilding JS bundles (may take ~1 min)..."
docker compose exec -T web yarn webpack-development

echo "Restarting web..."
docker compose restart web

echo "Done. Open ONE URL consistently:"
echo "  http://localhost:3000/courses/1/assignments/1"
echo "If domain.yml development.domain is localhost, do not mix with the EC2 IP in the same browser session."
