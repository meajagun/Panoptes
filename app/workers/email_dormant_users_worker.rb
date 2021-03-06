class EmailDormantUsersWorker
  include Sidekiq::Worker

  class DoNotRunOnStagingError < StandardError; end

  # skip retries for this job so we don't email users multiple times
  sidekiq_options retry: 0, queue: :data_low

  def perform(num_days_since_activity, only_user_ids_ending_in)
    raise DoNotRunOnStagingError if Rails.env.staging?

    user_ids_ending_in_scope = User.subset_selection(only_user_ids_ending_in)
    User.dormant(num_days_since_activity, user_ids_ending_in_scope) do |dormant_user|
      DormantUserMailerWorker.perform_async(dormant_user.id)
    end
  end
end
