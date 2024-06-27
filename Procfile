web: bundle exec puma -C config/puma.rb
worker: bundle exec sidekiq -c ${SIDEKIQ_CONCURRENCY:-5} -q critical,2 -q mailers -q default -q low