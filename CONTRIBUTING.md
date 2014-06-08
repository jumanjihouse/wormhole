Contributing
============

Topic branch + pull request (PR)
--------------------------------

To submit a patch, fork the repo and work within
a [topic branch](http://progit.org/book/ch3-4.html) of your fork.

1. Bootstrap your dev environment

   ```bash
   script/bootstrap
   ```

1. Set up a remote tracking branch

    ```bash
    git checkout -b <branch_name>

    # Initial push with `-u` option sets remote tracking branch.
    git push -u origin <branch_name>
    ```

1. Ensure your branch is up-to-date:

    ```bash
    git fetch --prune upstream
    git rebase upstream/master
    git push -f
    ```

1. Submit a [Pull Request](https://help.github.com/articles/using-pull-requests)
   - Participate in [code review](https://github.com/features/projects/codereview)
   - Participate in [code comments](https://github.com/blog/42-commit-comments)

1. [wercker](https://app.wercker.com/#applications/5348013a85c557fb5700aa1d)
   automatically runs the test harness against each pull request and push.
   You can also run tests locally via:

   ```bash
   script/test
   ```


Diff churn
----------

Please minimize diff churn to enhance git history commands.

* Arrays should usually be multi-line with trailing commas.

Update `.rubocop.yml` if necessary to favor minimal churn.


Linear history
--------------

Use `git rebase upstream/master` to update your branch.

* You **must** force-push after rebasing.
* We **never force-push** to master.

The primary reason for this is to maintain a clean, linear history
via "fast-forward" merges to master.
A clean, linear history in master makes it easier
to troubleshoot regressions and follow the timeline.
