name="$(git config --global user.name)"
mail="$(git config --global user.email)"

[[ x$name == x ]] && echo "WARN: 'git config --global user.name' is blank" >&2
[[ x$mail == x ]] && echo "WARN: 'git config --global user.email' is blank" >&2
:
