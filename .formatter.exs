[
  inputs: [
    "mix.exs",
    "{config,lib,test}/**/*.{ex,exs}"
  ],
  locals_without_parens: [
    # Ecto
    ## schema
    field: :*,
    belongs_to: :*,
    has_one: :*,
    has_many: :*,
    many_to_many: :*,
    embeds_one: :*,
    embeds_many: :*,
    ## migration
    create: :*,
    create_if_not_exists: :*,
    alter: :*,
    drop: :*,
    drop_if_exists: :*,
    rename: :*,
    add: :*,
    remove: :*,
    modify: :*,
    execute: :*,
    # Phoenix
    ## routes
    resources: :*,
    ## controllers
    plug: :*,
    action_fallback: :*
  ]
]
