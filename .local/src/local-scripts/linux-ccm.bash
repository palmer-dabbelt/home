branch="master"
compose="--compose"
to=()
while [[ "$1" != "" ]]
do
    case "$1" in
    --to)         to+=("$2");                     shift 2;;
    --no-compose) compose="";                     shift 2;;
    *)         echo "$0: unknown argument $1";    exit 1;;
    esac
done

if [[ "$to" == "" ]]
then
    echo "$0: some --to argument must be provided" >&2
    exit 1
fi

function join_by { local IFS="$1"; shift; echo "$*"; }

cc=($(git diff "$branch" \
	| ./scripts/get_maintainer.pl --no-roles --no-rolestats \
	| sed 's/.*<\([A-Za-z0-9.+-]*@[A-Za-z0.9.+-]*\)>/\1/' | sed 's/<//g' | sed 's/>//g' \
	| xargs echo))

set -x
git send-email --to "$(join_by , "${to[@]}")" --cc "$(join_by , "${cc[@]}")" "$compose" "$branch"
