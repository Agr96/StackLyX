import os
import requests
from pathlib import Path

# Define asset URLs and their target paths
ASSETS = [
    {
        'url': 'https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css',
        'path': 'static/css/bootstrap.min.css'
    },
    {
        'url': 'https://cdn.datatables.net/1.13.4/css/dataTables.bootstrap5.min.css',
        'path': 'static/css/dataTables.bootstrap5.min.css'
    },
    {
        'url': 'https://code.jquery.com/jquery-3.6.0.min.js',
        'path': 'static/js/jquery-3.6.0.min.js'
    },
    {
        'url': 'https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js',
        'path': 'static/js/bootstrap.bundle.min.js'
    },
    {
        'url': 'https://cdn.datatables.net/1.13.4/js/jquery.dataTables.min.js',
        'path': 'static/js/jquery.dataTables.min.js'
    },
    {
        'url': 'https://cdn.datatables.net/1.13.4/js/dataTables.bootstrap5.min.js',
        'path': 'static/js/dataTables.bootstrap5.min.js'
    }
]

def create_directories():
    """Create static/css and static/js directories if they don't exist."""
    os.makedirs('static/css', exist_ok=True)
    os.makedirs('static/js', exist_ok=True)

def download_asset(url, path):
    """Download a file from a URL and save it to the specified path."""
    try:
        response = requests.get(url, timeout=10)
        response.raise_for_status()  # Raise an error for bad status codes
        with open(path, 'wb') as f:
            f.write(response.content)
        print(f"Successfully downloaded: {path}")
        return True
    except requests.RequestException as e:
        print(f"Failed to download {url}: {e}")
        return False

def check_missing_assets():
    """Check for missing assets and return a list of missing files."""
    missing = []
    for asset in ASSETS:
        if not Path(asset['path']).exists():
            missing.append(asset['path'])
    return missing

def main():
    print("Starting asset download...")
    create_directories()
    
    # Download all assets
    for asset in ASSETS:
        download_asset(asset['url'], asset['path'])
    
    # Check for missing files
    missing_files = check_missing_assets()
    if missing_files:
        print("\nWARNING: The following assets are missing:")
        for file in missing_files:
            print(f"- {file}")
        print("The app may not function correctly without these files.")
    else:
        print("\nAll assets downloaded successfully!")

if __name__ == '__main__':
    main()
