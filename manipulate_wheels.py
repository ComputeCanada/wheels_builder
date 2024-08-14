#!/cvmfs/soft.computecanada.ca/custom/python/envs/manipulate_wheels/bin/python3
import os
import sys
import re
import argparse
import traceback
from packaging import version
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
    parser.add_argument("-a", "--add_req", nargs="+", default=None, help="Add requirements to the wheel.")
    parser.add_argument("-r", "--remove_req", nargs="+", default=None, help="Remove requirements from the wheel.")
    parser.add_argument("--set_min_numpy", default=None, help="Sets the minimum required numpy version.")
    parser.add_argument("--set_lt_numpy", default=None, help="Sets the lower than (<) required numpy version.")
    parser.add_argument("--inplace", action='store_true', help="Work in the same directory as the existing wheel instead of a temporary location")
    parser.add_argument("--force", action='store_true', help="If combined with --inplace, overwrites existing wheel if the resulting wheel has the same name")
    parser.add_argument("-p", "--print_req", action='store_true', help="Prints the current requirements")
    parser.add_argument("-v", "--verbose", action='store_true', help="Displays information about what it is doing")
    parser.add_argument("-t", "--add_tag", action="store", default=None, help="Specifies a tag to add to wheels", dest="tag")

    return parser

def main():
    args = create_argparser().parse_args()

    if not args.inplace:
        print("Resulting wheels will be in directory %s" % TMP_DIR)
    # still create the TMP_DIR if it does not exist, as it will be used temporarily
    if not os.path.exists(TMP_DIR):
        os.makedirs(TMP_DIR)

    actions = [args.insert_local_version, args.update_req, args.set_min_numpy, args.set_lt_numpy, args.print_req, args.add_req, args.remove_req, args.tag]
    if not any(actions):
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
                current_version = str(wf.version)
                new_version = current_version
                if args.tag:
                    if args.tag in new_version:
                        if args.verbose:
                            print("wheel %s already has the %s tag. Skipping" % (w, args.tag))
                    else:
                        if "+" in new_version:
                            # ensure the tag is the first item after the +
                            version_parts = new_version.split("+")
                            version_parts[1] = "%s.%s" % (args.tag, version_parts[1])
                            new_version = "+".join(version_parts)
                        else:
                            new_version += "+%s" % args.tag

                if args.insert_local_version:
                    if LOCAL_VERSION in current_version:
                        if args.verbose:
                            print("wheel %s already has the %s local version. Skipping" % (w, LOCAL_VERSION))
                    else:
                        if "+" in new_version:
                            new_version += ".%s" % LOCAL_VERSION
                        else:
                            new_version += "+%s" % LOCAL_VERSION

                if new_version != current_version:
                    if args.verbose:
                        print("Updating version of wheel %s to %s" % (w, new_version))
                    wf2 = WheelFile.from_wheelfile(wf, file_or_path=TMP_DIR, version=new_version)

                if args.update_req:
                    if not wf2:
                        wf2 = WheelFile.from_wheelfile(wf, file_or_path=TMP_DIR, version=new_version)
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

                if args.add_req:
                    if not wf2:
                        wf2 = WheelFile.from_wheelfile(wf, file_or_path=TMP_DIR, version=new_version)
                    for req in args.add_req:
                        req_name = re.split(REQ_SEP, req)[0]
                        new_req = []
                        # first, ensure that the requirement does not already exist in this wheel
                        for curr_req in wf2.metadata.requires_dists:
                            curr_req_name = re.split(REQ_SEP, curr_req)[0]
                            if curr_req_name == req_name:
                                print(f"{w}: requirement {req_name} already present. Please use --update_req if you want to update it")
                                return
                            else:
                                new_req += [curr_req]
                        # then add the new requirement
                        new_req += [req]
                        wf2.metadata.requires_dists = new_req

                if args.remove_req:
                    if not wf2:
                        wf2 = WheelFile.from_wheelfile(wf, file_or_path=TMP_DIR, version=new_version)
                    req_to_remove_found = False
                    for req_to_remove in args.remove_req:
                        req_to_remove_name = re.split(REQ_SEP, req_to_remove)[0]
                        new_req = []
                        # first, ensure that the requirement does exist in this wheel
                        for curr_req in wf2.metadata.requires_dists:
                            curr_req_name = re.split(REQ_SEP, curr_req)[0]
                            # exact match, with version specifier
                            if curr_req == req_to_remove:
                                print(f"{w}: requirement {req_to_remove} found. Removing it")
                                req_to_remove_found = True
                            # no version was specified, match on name only
                            elif req_to_remove_name == req_to_remove and curr_req_name == req_to_remove_name:
                                print(f"{w}: requirement {req_to_remove_name} found. Removing it")
                                req_to_remove_found = True
                            else:
                                new_req += [curr_req]
                        # then update the requirement list
                        wf2.metadata.requires_dists = new_req

                    if not req_to_remove_found:
                        print(f"{w}: requirement {req_to_remove} was to be removed, but was not found.")

                if args.set_min_numpy or args.set_lt_numpy:
                    if not wf2:
                        wf2 = WheelFile.from_wheelfile(
                            wf, file_or_path=TMP_DIR, version=new_version)
                    new_req = []
                    numpy_req_found = False
                    for curr_req in wf.metadata.requires_dists:
                        if re.search(r'^numpy(\W|$)', curr_req):
                            numpy_req_found = True
                            if args.verbose:
                                print('Found numpy dependency.')

                            dependency, *markers = curr_req.split(';')

                            version_specifiers = dependency.replace("numpy","").replace("(","").replace(")","").strip().split(',')
                            to_req_tokens = ["numpy",""]
                            if markers:
                                to_req_tokens += [';' + ';'.join(markers)]

                            min_numpy_set = False
                            lt_numpy_set = False
                            if version_specifiers:
                                for i, version_spec in enumerate(version_specifiers):
                                    version_number = re.sub(REQ_SEP, '', version_spec)
                                    if '>' in version_spec:
                                        # case: old minimum version is lower than our minimal version
                                        if args.set_min_numpy and version.parse(version_number) < version.parse(args.set_min_numpy):
                                            version_specifiers[i] = '>='+args.set_min_numpy
                                            min_numpy_set = True
                                        # case: existing minimum version is higher than our maximum version
                                        elif args.set_lt_numpy and version.parse(version_number) >= version.parse(args.set_lt_numpy):
                                            print(f"Error: this wheel {w} requires numpy {version_spec}, but requested numpy is <{args.set_lt_numpy}.")
                                            sys.exit(1)
                                    elif '<' in version_spec:
                                        # case: old maximum version is higher than our maximumversion
                                        if args.set_lt_numpy and version.parse(version_number) >= version.parse(args.set_lt_numpy):
                                            version_specifiers[i] = '<'+args.set_lt_numpy
                                            lt_numpy_set = True
                                        # case: existing maximum version is higher than our minimal version
                                        if args.set_min_numpy and version.parse(version_number) <= version.parse(args.set_min_numpy):
                                            print(f"Error: this wheel {w} requires numpy {version_spec}, but requested numpy is >={args.set_min_numpy}.")
                                            sys.exit(1)
                            # no conflict, but a > requirement was not found, so adding one
                            if args.set_min_numpy and not min_numpy_set:
                                version_specifiers += ['>='+args.set_min_numpy]
                            # no conflict, but a < requirement was not found, so adding one
                            if args.set_lt_numpy and not lt_numpy_set:
                                version_specifiers += ['<'+args.set_lt_numpy]
                            to_req_tokens[1] = '(' + ','.join(version_specifiers) + ')'

                            to_req = ' '.join(new_req_tokens)
                            if curr_req != to_req:
                                if args.verbose:
                                    print(f"{w}: updating requirement {curr_req} to {to_req}")
                                new_req.append(to_req)
                            else:
                                if args.verbose:
                                    print(f"{w}: no change needed (from {curr_req} to {to_req})")
                                new_req.append(curr_req)
                            # sys.exit(1) #TODO remove
                        else:
                            new_req.append(curr_req)

                    if not numpy_req_found:
                        to_req = 'numpy (>=' + args.set_min_numpy + ')'
                        print(f"{w}: numpy requirement not found, adding {to_req}")
                        new_req.append(to_req)

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
                            sys.exit(1)
                    os.rename(wf2_full_filename, target_file)
                print("New wheel created %s" % target_file)
        except Exception as e:
            print("Exception: %s" % traceback.format_exc())
            continue

if __name__ == "__main__":
    main()
