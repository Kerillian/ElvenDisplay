<p align="center">
  <img width="256" height="256" src="./materials/elven_display/icon.png"></br>
  Icon Credit: Shmish
</p>

# 📝About
Elven Display is an addon for [Garry's Mod](https://gmod.facepunch.com/) that allows you to display images and videos in-game. It was built with the intent of being used on the x64 branch with Chrome, though it does have backwards compatibility with the normal release branch and Awesomium.<br/><br/>

# ⚙️Features

- Display media like PNGs, JPGs, GIFs, APNGs, and WEBMs (No audio).
- Scale displayed images (Aspect ratio aware).
- Display random images. (Safe rating is default. Admin only by default.)
- Client can opt out of viewing the displays.
- Manage url filters.
- Manage allowed mime types.
- Limit the size of images (Both dimension and file size).
- Make displays admin only.
- Allow admins to bypass url filters.
- Admin menu to view currently spawned displays.<br/><br/>

# ⌨️Commands

### Client
| Command                     | Type | Default | Help                            |
|-----------------------------|------|---------|---------------------------------|
| cl_elvendisplay_show        | bool | 1       | Enable the displays.            |
| cl_elvendisplay_closeonsave | bool | 1       | Close the editing menu on save. |
| cl_elvendisplay_sync        | cmd  | nil     | Resync content on all displays. |


### Server / Administrative
| Command                            | Type  | Default | Help                                                                      |
|------------------------------------|-------|---------|---------------------------------------------------------------------------|
| sv_elvendisplay_maxsize            | int32 | 1280    | Will limit images to this size in pixels. (Checks both width and height). |
| sv_elvendisplay_kblimit            | int32 | 10000   | The maximum file size of media in kilobytes.                              |
| sv_elvendisplay_random             | bool  | 1       | Enable the random button inside the edit UI.                              |
| sv_elvendisplay_random_adminonly   | bool  | 1       | Random button will only show for admins.                                  |
| sv_elvendisplay_adminonly          | bool  | 0       | Makes it so only admins can edit the panels.                              |
| sv_elvendisplay_filterignoreadmins | bool  | 1       | Admins can bypass link filters. Mime type checks are still enforced.      |
| sv_elvendisplay_filters            | cmd   | nil     | List the currently used filters.                                          |
| sv_elvendisplay_filters_add        | cmd   | nil     | Add a filter to the filter list.                                          |
| sv_elvendisplay_filters_remove     | cmd   | nil     | Remove a filter from the filter list.                                     |
| sv_elvendisplay_mimetypes          | cmd   | nil     | List the currently allowed mime types.                                    |
| sv_elvendisplay_mimetypes_add      | cmd   | nil     | Add a mime type to the mime type list.                                    |
| sv_elvendisplay_mimetypes_remove   | cmd   | nil     | Remove a mime type from the mime type list.                               |
| sv_elvendisplay_settings_reset     | cmd   | nil     | Reset all ElvenDisplay Settings.                                          |
| sv_elvendisplay_view               | cmd   | nil     | Admin menu for viewing all displays on the server.                        |