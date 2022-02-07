#!/cvmfs/soft.computecanada.ca/custom/python/envs/manipulate_wheels/bin/python3
import os
import sys
import re
import argparse
import traceback
from wheelfile import WheelFile


LOCAL_VERSION = "computecanada"
TMP_DIR = "./tmp"
# list of separators to split a requirement into name and version specifier
# i.e. numpy >= 1.19
REQ_SEP = "=|<|>|~|!| "
RENAME_SEP = "->"
def create_argparser():
    """
    Returns an arguments parser for `patch_wheel` command.
    Note : sys.argv is not parsed yet, must call `.parse_args()`.
    """

    class HelpFormatter(argparse.RawDescriptionHelpFormatter, argparse.ArgumentDefaultsHelpFormatter):
        """ Dummy class for RawDescription and ArgumentDefault formatter """

    description = "Manipulate wheel files"

    epilog = ""

    parser = argparse.ArgumentParser(prog="manipulate_wheels",
                                     formatter_class=HelpFormatter,
                                     description=description,
                                     epilog=epilog)

    parser.add_argument("-w", "--wheels", nargs="+", required=True, default=None, help="Specifies which wheels to patch")
    parser.add_argument("-i", "--insert_local_version", action='store_true', help="Adds the +computecanada local version")
    parser.add_argument("-u", "--update_req", nargs="+", default=None, help="Updates requirements of the wheel.")
    parser.add_argument("--inplace", action='store_true', help="Work in the same directory as the existing wheel instead of a temporary location")
    parser.add_argument("--force", action='store_true', help="If combined with --inplace, overwrites existing wheel if the resulting wheel has the same name")
    parser.add_argument("-p", "--print_req", action='store_true', help="Prints the current requirements")
    parser.add_argument("-v", "--verbose", action='store_true', help="Displays information about what it is doing")

    return parser

def main():
    args = create_argparser().parse_args()

    if not args.inplace:
        print("Resulting wheels will be in directory %s" % TMP_DIR)
    # still create the TMP_DIR if it does not exist, as it will be used temporarily
    if not os.path.exists(TMP_DIR):
        os.makedirs(TMP_DIR)

    if not args.insert_local_version and not args.update_req and not args.print_req:
        print("No action requested. Quitting")
        return

    for w in args.wheels:
        wf_basename = os.path.basename(w)
        wf_dirname = os.path.dirname(w)
        if args.print_req:
            print("Requirements for wheel %s:" % w)
        try:
            with WheelFile(w) as wf:
                if args.print_req:
                    print("==========================")
                    for req in wf.metadata.requires_dists:
                        print(req)
                    print("==========================")
                    continue

                wf2 = None
                version = str(wf.version)
                if args.insert_local_version:
                    if LOCAL_VERSION in version:
                        if args.verbose:
                            print("wheel %s already has the %s local version. Skipping" % (w, LOCAL_VERSION))
                    else:
                        if "+" in version:
                            version += ".%s" % LOCAL_VERSION
                        else:
                            version += "+%s" % LOCAL_VERSION
                        if args.verbose:
                            print("Updating version of wheel %s to %s" % (w, version))
                wf2 = WheelFile.from_wheelfile(wf, file_or_path=TMP_DIR, version=version)

                if args.update_req:
                    if not wf2:
                        wf2 = WheelFile.from_wheelfile(
                            wf, file_or_path=TMP_DIR, version=version)
                    for req in args.update_req:
                        # If an update does rename a requirement, split from and to, else ignore
                        from_req, to_req = req.split(RENAME_SEP) if RENAME_SEP in req else (req, req)
                        req_name = re.split(REQ_SEP, from_req)[0]
                        new_req = []
                        for curr_req in wf2.metadata.requires_dists:
                            curr_req_name = re.split(REQ_SEP, curr_req)[0]
                            # if it is the same name, update the requirement
                            if curr_req_name == req_name:
                                if args.verbose:
                                    print(f"{w}: updating requirement {curr_req} to {to_req}")
                                new_req += [to_req]
                            else:
                                new_req += [curr_req]
                        wf2.metadata.requires_dists = new_req
                wf2_full_filename = wf2.filename
                wf2_dirname = os.path.dirname(wf2_full_filename)
                wf2_basename = os.path.basename(wf2_full_filename)
                target_file = wf2_full_filename
                wf2.close()
                if args.inplace:
                    target_file = os.path.join(wf_dirname, wf2_basename)
                    if os.path.exists(target_file):
                        if args.force:
                            print("Since --force was used, overwriting existing wheel")
                            os.remove(target_file)
                        else:
                            print("Error, resulting wheels has the same name as existing one. Aborting.")
                            exit(1)
                    os.rename(wf2_full_filename, target_file)
                print("New wheel created %s" % target_file)
        except Exception as e:
            print("Exception: %s" % traceback.format_exc())
            continue

if __name__ == "__main__":
    main()
