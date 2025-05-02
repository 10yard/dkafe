## :page_facing_up: The `ssf.txt` format

The `ssf.txt` file format consists of 1000's of rom names combined with frame numbers to be skipped for that rom. When the a game is loaded in MAME, the plugin loads `ssf.txt` and looks for the rom name to determine how many frames to skip. The format is as follows:

`<rom_name>,<startup_frames>`

Example:

```
...
radm,14
radr,79
radrad,439
raflesia,15
ragnagrd,243
raiden,42
raiden2,30
raiders,550
raiders5,1443
raimais,529
rainbow,376
rallybik,517
rallyx,760
...
```

:exclamation: :exclamation: For any given game, if it's frame target is missing from `ssf.txt`, it will default to `0`.

## :warning: Do not edit `ssf.txt` :warning: 

Nothing terrible will happen if you do, but any changes/customizations to `ssf.txt` will be :bomb: overwritten if you install a new version of this plugin. Instead, add customizations to `ssf_custom.txt`.

## :memo: `ssf_custom.txt`

Any customizations to frame numbers should be added to `ssf_custom.txt`. The format is the exact same as `ssf.txt`. Additionally, any changes made to frames in the Plugin Options menu in MAME will be saved to `ssf_custom.txt` when you exit MAME.

:exclamation: :exclamation: A rom entry in `ssf_custom.txt` WILL TAKE PRIORITY over the same rom entry in `ssf.txt`.

Example:

- `ssf.txt` contains `galaga,870`
- You add `galaga,900` to `ssf_custom.txt`
- When starting up `galaga` the plugin will skip `900` frames instead of `870`

:point_right: When the plugin first runs, it will create a blank `ssf_custom.txt` in the plugin directory.

## Startup :arrow_right: vs. Soft Reset :leftwards_arrow_with_hook:

- A _startup_ is when you initially start a game with MAME
- A _soft reset_ is when you press F3, which instantly resets the game
- A _hard reset_ is when you press SHIFT+F3, which exits the game and immediately starts it up again
- This plugin treats a _startup_ and _hard reset_ the same but a _soft reset_ differently

A small number of games go through different procedures with a _startup_ (or _hard reset_) vs. a _soft reset_. In these situations a _soft reset_ requires a different number of frames that must be skipped. An example of this is the 1984 arcade game [Zwackery](https://www.arcade-museum.com/Videogame/zwackery).

:star: To faciliate different frame values for _soft resets_, `ssf.txt` and `ssf_custom.txt` both support an _additional, optional_ format:

`<rom_name>,<startup_frames>|<reset_frames>`

Example: `zwackery,750|120`

When starting up `zwackery` 750 frames will be skipped. If you perform a _soft reset_ (F3), only 120 frames will be skipped.

## :muscle: `ssf.txt` Contributions and Updates

`ssf.txt` is an old file that was [filled with frame numbers back in 2004](https://forum.arcadecontrols.com/index.php/topic,48674.msg) by dedicated members of the [Build Your Own Arcade Controls forum](https://forum.arcadecontrols.com/).

The majority of startup frames are most likely still accurate from 2004 but a lot can change since then. New roms have been added to MAME. Some old roms might have been changed or redumped, resulting in different startup procedures. If you find any startup frames in `ssf.txt` to be inaccurate or missing, you can easily contribute changes to the project so everyone can use them.

:computer: Fork the repository, commit your changes to `ssf.txt` and create a pull request back to the `develop` branch of this repository. If approved, changes will make their way into a future release of the plugin. :heart:

For more information on forks, commits and pull requests, see [Github's](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/getting-started/about-collaborative-development-models
) [official](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/working-with-forks/fork-a-repo
) [documentation](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request-from-a-fork
).

:warning: Don't commit changes to `ssf_custom.txt`. It is not to be included in distribution of the plugin in order to prevent overwriting anyone's customizations.
