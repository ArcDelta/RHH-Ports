# Jeod's Ports
You can use [Downgit](https://downgit.github.io/#/home) to download specific folders in this repository without having to clone the whole thing.

Whether you're new to retro handhelds, a developer who came across this repository and noticed their game has a port, or a developer seeking information, I can't recommend enough this video by WULFF DEN which encapsulates the whole idea pretty well.

<div align="center">
  <table>
    <tr>
      <td align="center">
        <p align="center">Playing Steam Games on your Retro Handheld</p>  
        <a href="https://www.youtube.com/watch?v=I4Utn3N_dZo">
          <img src="https://img.youtube.com/vi/I4Utn3N_dZo/0.jpg" alt="Playing Steam Games on your Retro Handheld by WULFF DEN" width="400"/>
        </a>
      </td>
    </tr>
  </table>
</div>

## Port Capability Requirements
Some of the ports in this repository have minimum requirements. Be sure to check the `port.json` file for a port to see if it lists any of the following requirements:

- `hires`: The port will work best with a screen resolution greater than `640x480`.
- `!lowres`: The port will work best with a screen resolution that is at minimum `640x480`.
- `power`: The port will perform best with a device with more power than the `rk3326` cpu.
- `opengl`: The port requires OpenGL (not OpenGLES). This means a mainline custom firmware.
- `wide`: The port demands an aspect ratio above 4:3.
- `analog_#`: The port requires analog sticks.

## Runtimes
Some of my ports require runtimes--mounted squashfs files that contain common scripts, programs, etc. These are found in the `runtimes` folder of this repository and should be placed in `PortMaster/libs` on your device. For large runtimes (like GMToolkit), the squashfs file may be split into multiple parts. You’ll need to recombine the parts before transferring to your device. Download all the parts and, in the same folder, do one of the following:

On Linux and MacOS:

`cat gmtoolkit.aarch64.squashfs.part.* > gmtoolkit.aarch64.squashfs`

On Windows:

cmd: `copy /b gmtoolkit.aarch64.squashfs.part.001 + gmtoolkit.aarch64.squashfs.part.002 + gmtoolkit.aarch64.squashfs.part.003 gmtoolkit.aarch64.squashfs`

powershell: `Get-ChildItem -Filter "gmtoolkit.aarch64.squashfs.part.*" | Sort-Object Name | Get-Content -Encoding Byte -ReadCount 0 | Set-Content gmtoolkit.aarch64.squashfs -Encoding Byte`

## Keeping up
You can keep up with ports that I consider "complete" by checking the [commit history](https://github.com/JeodC/PortMaster-Games/commits/main) for the format `[PORTNAME] Move to released folder`. You can also browse the [unreleased](https://github.com/JeodC/PortMaster-Games/tree/main/ports/unreleased) folder to see what I'm working on. If you star and watch this repository, you'll get GitHub notifications when I make changes.

## Contributing
If you see potential for improvements to my ports, I'm open to suggestions and pull requests--especially for unreleased ports, which are either in progress or in limbo for one reason or another. Please do not open issues to suggest new ports unless you're certain they can be ported. Although, if you're certain a game can be ported, why not do it yourself?

Please review the [Contribution Guidelines](.github/CONTRIBUTING.md) before proceeding with contributions.

## Donating
I love bringing indie games to the linux arm64 platform, and seeing people experience games through a new medium! Making legal ports with commercial indie games isn't free though. I accept donations on my [Ko-Fi](https://ko-fi.com/jeodc) page. All donations I receive go towards further port research -- mostly purchasing commercial games to develop new ports with.

## Licensing
All of these port wrappers are MIT licensed except for the following:

- Game assets as a part of "ready to run" ports are licensed for distribution through PortMaster, but the MIT license does *not* apply to the assets.
- Open source tools like [GMLoader-Next](https://github.com/PortsMaster/gmloader-next?tab=readme-ov-file) and [GMTools](https://github.com/cdeletre/gmtools) have their own licenses and are not necessarily MIT.
- Open source projects like Ship of Harkinian may also have their own licenses.
- Libraries used by the ports have their own licenses.

In short, the MIT license applies only to custom parts of the port wrappers, typically the bash files.
