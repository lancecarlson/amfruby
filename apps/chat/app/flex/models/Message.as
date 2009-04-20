package models
{
  [RemoteClass(alias="Message")]
  [Bindable]
  public class Message
  {
    public var id: Number;
    public var message: String;
  }
}