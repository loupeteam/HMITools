<?xml version='1.0' encoding='utf-8'?>
<SwConfiguration xmlns="http://br-automation.co.at/AS/SwConfiguration" CpuAddress="">
  <TaskClass Name="Cyclic#1">
    <Task Name="Default" Source="Programs.Default.prg" Memory="UserROM" Language="ANSIC" Debugging="true" />
  </TaskClass>
  <TaskClass Name="Cyclic#2" />
  <TaskClass Name="Cyclic#3" />
  <TaskClass Name="Cyclic#4" />
  <TaskClass Name="Cyclic#5" />
  <TaskClass Name="Cyclic#6" />
  <TaskClass Name="Cyclic#7" />
  <TaskClass Name="Cyclic#8" />
  <Libraries>
    <LibraryObject Name="ringbuflib" Source="Libraries.Loupe.ringbuflib.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="logthat" Source="Libraries.Loupe.logthat.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="stringext" Source="Libraries.Loupe.stringext.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="HMITools" Source="Libraries.Loupe.HMITools.lby" Memory="UserROM" Language="IEC" Debugging="true" />
  </Libraries>
</SwConfiguration>
