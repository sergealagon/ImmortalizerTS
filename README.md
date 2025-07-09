
# ImmortalizerTS

Keep your apps running in the foreground indefinitely, even if they are in the background!

**For iOS 15+**

_This is the TrollStore version of the tweak [Immortalizer](https://github.com/sergealagon/Immortalizer), with some changes and tricks to keep apps running in the foreground without jailbreak._

### Details
- Just like the tweak, it can make apps stay in the foreground.

- Without a jailbreak, its approach for making apps run in the foreground indefinitely works a bit different compared to the tweak version. 
- Despite that, this can still display UI over springboard such as toast and windowed scenes.


### Limitations
- Depending on the app (these apps have their own notification when they are open; e.g. WhatsApp), it cannot force an app to show notifications if it is foregrounded.
- If an immortalized app supports multi-scene window, it can only immortalize the scene instance created inside, so you can only use the said app inside here.
- If an app supports multi-scene, they can be used in window mode that floats over springboard by long pressing the immortalized app. **However, keyboard doesn't work as it is invisible in window mode.**
- If ImmortalizerTS is killed, all immortalized apps will return to its normal background state.

### [Note]: This is still in beta
    1. It is expected to work on all apps, but I cannot 100% guarantee. 
    2. Rotations may be a bit janky, especially when app is in window mode. 
    3. Some multi scene apps don't follow safe area insets, so they may appear overlapped.

# License
    Copyright (C) 2025  Serge Alagon

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>. 

## Credits
**@khanhduytran0's [FrontBoardAppLauncher](https://github.com/khanhduytran0/FrontBoardAppLauncher)** - reference usage of FrontBoard framework.