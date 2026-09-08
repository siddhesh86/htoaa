import subprocess

def xrootd_file_exists_cli(redirector, file_path):
    """
    Checks file existence by querying the system's native xrdfs command line tool.
    """
    url = f"root://{redirector}"
    
    # Running 'xrdfs root://server stat /path/to/file'
    # stdout/stderr are redirected to DEVNULL to keep output clean
    cmd = ["xrdfs", url, "stat", file_path]
    
    result = subprocess.run(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    
    # A return code of 0 means the file exists and is accessible
    return result.returncode == 0

# Example Usage
redirector_host = "xrootd-cms.infn.it"
cms_path = "/store/group/phys_susy/HToaaTo4b/LHE/SM_HTo4b_LO_13p6/2026_09_01/pp-ggH-4b-single.lhe"

if xrootd_file_exists_cli(redirector_host, cms_path):
    print(f"{redirector_host}: {cms_path} File exists!")
else:
    print("File not found.")
