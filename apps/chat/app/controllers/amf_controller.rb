class AmfController < ApplicationController
  def gateway    
    amf_response = []
    if request.env['CONTENT_TYPE'].to_s.match(/x-amf/) 
      headers['Content-Type'] = "application/x-amf"
      AMF.deserialize(request.raw_post)
    end
    
    send_data(amf_response, {:type => headers['Content-Type'], :disposition => 'inline'})
  end
end


# http://opensource.adobe.com/wiki/download/attachments/1114283/amf3_spec_05_05_08.pdf
# http://opensource.adobe.com/wiki/download/attachments/1114283/amf0_spec_121207.pdf?version=1
module AMF    
  TYPES_0 = {
    0x00 => "read_double",       # Number
    0x01 => "Boolean",       # Boolean
    0x02 => "String",        # String
    0x03 => "Object",        # Object
    0x04 => "MovieClip",     # MovieClip
    0x05 => nil,             # NULL
    0x06 => nil,             # Undefined
    0x07 => "Reference",     # Reference. TODO
    0x08 => "ECMAArray",     # ECMA Array. TODO
    0x09 => "ObjectEnd",     # Object End
    0x0A => "StrictArray",   # Strict Array
    0x0B => "Date",          # Date
    0x0C => "LongString",    # Long String
    0x0D => "Unsupposed",    # Unsupported
    0x0E => "Recordset",     # Recordset
    0x0F => "XML",           # XML
    0x10 => "TypedObject",   # Typed Object
    0x11 => "AMF3"           # AMF3
  }

  TYPES_3 = {
    0x00 => nil,           # Undefined
    0x01 => nil,           # Null
    0x02 => false,         # False
    0x03 => true,          # True
    0x04 => "Integer",       # Integer
    0x05 => "Double",        # Double
    0x06 => "String",        # String
    0x07 => "XMLDoc",            # XML Doc
    0x08 => "Date",          # Date
    0x09 => "Array",         # Array
    0x0A => "Object",        # Object
    0x0B => "XML",            # XML
    0x0C => "ByteArray"            # Byte Array
  }
  
  module BinaryReader
    def read_boolean
      read_byte == 1
    end
    
    # An unsigned byte, 8-bits of data, an octet 
    def read_u8
      read_byte.unpack('c').first
    end
    
    # An unsigned 16-bit integer in big endian (network) byte order
    def read_u16
      read_bytes(2).unpack('n').first
    end
    
    # An signed 16-bit integer in big endian (network) byte order 
    def read_s16
      read_bytes(2).unpack('s').first
    end
    
    # An unsigned 32-bit integer in big endian (network) byte order
    def read_u32
      read_bytes(4).unpack('N').first
    end
    
    # 8 byte IEEE-754 double precision floating point value in network byte order (sign bit in low memory).
    def read_double
      read_bytes(8).unpack('G').first
    end

    def read_byte
      read_bytes(1)
    end

    def read_bytes(length=1)
      bytes = @binary_stream[0, length]
      @binary_stream[0, length] = ''
      bytes
    end

    def read(type)
      if TYPES_0.has_key?(type)
        return_or_type = TYPES_0[type]
        if return_or_type.is_a?(String)
          self.send(TYPES_0[type])
        else
          return return_or_type
        end
      elsif TYPES_3.has_key?(type)
        puts "AMF3"
      end
    end
  end
  
  class << self
    include BinaryReader
    
    def deserialize(binary_stream)
      puts "deserializing..."
      @binary_stream = binary_stream

      @version = read_u16
      @client = read_u16

      puts @version
      puts @client

      read_headers
      read_body

      # @binary_stream.each_byte do |byte|
      #   puts byte 
      # end
    end
    
    def read_headers
      puts "Headers"
      header_length = read_u16
      puts header_length

      header_length.times do
        name_length = read_u16
        puts name_length
        header_name = read_bytes(name_length)
        puts header_name
        # must_understand = read_boolean
        # puts must_understand
        # length = read_unsigned_long
        # puts length
        # type = read_u8
        # puts type
        # value = read(type)
        # puts value
      end
    end
    
    def read_body
      puts "Body"
      
      puts "target"
      target_length = read_u16
      puts target_length
      
      target = read_bytes(target_length)
      puts target
      
      puts "response"
      response_length = read_u16
      puts response_length
      
      puts "body of body"
      # body_length = read_u32
      # puts body_length
      
      12.times do
        puts read_u8
      end
      
      48.times do
        puts read_byte
      end
    
      # body_length.times do
        # service_uri = read_bytes(service_uri_length)
      # end
    end
  end  
end