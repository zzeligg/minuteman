require 'helper'

setup do
  Minuteman.redis = Redic.new("redis://127.0.0.1:6379/1")
  Minuteman.redis.call("FLUSHDB")
end

test "a connection" do
  assert_equal Minuteman.redis.class, Redic
end

test "models in minuteman namespace" do
  assert_equal Minuteman::User.create.key, "Minuteman::User:1"
end

test "an anonymous user" do
  user = Minuteman::User.create

  assert user.is_a?(Minuteman::User)
  assert !!user.uid
  assert !user.identifier
  assert user.id
end

test "access a user with and id or an uuid" do
  user = Minuteman::User.create(identifier: 5)

  assert Minuteman::User[user.uid].is_a?(Minuteman::User)
  assert Minuteman::User[user.identifier].is_a?(Minuteman::User)
end

test "track an anonymous user" do
  user = Minuteman.track("unknown")
  assert user.uid
end

test "track an user" do
  user = Minuteman::User.create

  assert Minuteman.track("login:successful", user)

  analyzer = Minuteman.analyze("login:successful")
  assert analyzer.day(Time.now.utc).count == 1
end
