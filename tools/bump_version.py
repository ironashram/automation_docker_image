import subprocess
from packaging.version import Version, InvalidVersion


def get_latest_tag():
    result = subprocess.run(['git', 'describe', '--tags', '--abbrev=0'],
                            stdout=subprocess.PIPE, text=True, check=True)
    return result.stdout.strip()


def bump_version(tag):
    try:
        version = Version(tag.lstrip('v'))
    except InvalidVersion as exc:
        raise ValueError(f"Invalid tag format: {tag}") from exc

    new_version = Version(f"{version.major}.{version.minor}.{version.micro + 1}")
    return f"v{new_version}"


def main():
    latest_tag = get_latest_tag()
    new_tag = bump_version(latest_tag)
    print(new_tag)


if __name__ == "__main__":
    main()
