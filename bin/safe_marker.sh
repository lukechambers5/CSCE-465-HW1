set -euo pipefail
DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." >/dev/null && pwd)"

[[ $# -eq 1 && "$1" == "course-marker" ]] || { echo "Usage: $0 course-marker" >&2; exit 1; }


mkdir -p "$DIR/markers"
echo "marker created: $(date -u +%FT%TZ)" > "$DIR/markers/marker.txt"
echo "OK: wrote $DIR/markers/marker.txt"
