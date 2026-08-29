#!/usr/bin/env bash

input=$(cat)

cwd=$(printf '%s' "$input" | jq -r '.workspace.current_dir // .cwd // empty')
real_home=$(eval echo "~$(whoami)" 2>/dev/null || echo "$HOME")
dir_display="🗂  ${cwd/#$real_home/~}"

branch=$(git -C "$cwd" rev-parse --abbrev-ref HEAD 2>/dev/null || true)
if [ -n "$branch" ]; then
  dir_display="$dir_display [$branch]"
fi

model_name=$(printf '%s' "$input" | jq -r '.model.display_name // empty')
model_id=$(printf '%s' "$input" | jq -r '.model.id // empty')
effort=$(printf '%s' "$input" | jq -r '.effort.level // "unknown"')
if [ -n "$model_id" ] && [ "$model_id" != "null" ]; then
  model_display="🤖 $model_name ($model_id) [$effort]"
else
  model_display="🤖 $model_name [$effort]"
fi

used_pct=$(printf '%s' "$input" | jq -r '.context_window.used_percentage // empty')
remaining_pct=$(printf '%s' "$input" | jq -r '.context_window.remaining_percentage // empty')
max_tokens=$(printf '%s' "$input" | jq -r '.context_window.context_window_size // empty')
if [ -n "$max_tokens" ] && [ "$max_tokens" != "null" ]; then
  max_tokens_display=$(awk -v t="$max_tokens" 'BEGIN{
    if (t>=1000000) printf "%gm", t/1000000;
    else if (t>=1000) printf "%gk", t/1000;
    else printf "%d", t;
  }')
fi

if [ -n "$used_pct" ] && [ "$used_pct" != "null" ]; then
  if [ -n "$max_tokens_display" ]; then
    ctx_display=$(printf '💭 %.0f%% / %.0f%% (%s)' "$used_pct" "$remaining_pct" "$max_tokens_display")
  else
    ctx_display=$(printf '💭 %.0f%% / %.0f%%' "$used_pct" "$remaining_pct")
  fi

  total_cells=10
  filled_cells=$(awk -v p="$used_pct" -v n="$total_cells" 'BEGIN{c=int(p/100*n+0.5); if(c>n)c=n; if(c<0)c=0; print c}')
  cell_color=$(awk -v p="$used_pct" 'BEGIN{if(p<50)print "32"; else if(p<80)print "33"; else print "31"}')
  cells=""
  for ((i = 1; i <= total_cells; i++)); do
    if ((i <= filled_cells)); then
      cells+="█"
    else
      cells+="░"
    fi
  done
  ctx_cells_display=$(printf '\033[%sm%s\033[0m' "$cell_color" "$cells")
else
  ctx_display='💭 n/a'
  ctx_cells_display=''
fi

cost=$(printf '%s' "$input" | jq -r '.cost.total_cost_usd // empty')
if [ -n "$cost" ] && [ "$cost" != "null" ]; then
  cost_display=$(printf '💰 $%.4f' "$cost")
else
  cost_display='💰 cost n/a'
fi

printf '%s | %s | %s %s | %s\n' "$dir_display" "$model_display" "$ctx_display" "$ctx_cells_display" "$cost_display"
