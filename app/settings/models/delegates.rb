module Carendar
  class SimpleTokenDelegate

    def tokenField(field, completionsForSubstring:substring,
                indexOfToken:index, indexOfSelectedItem:selected_index)
      NSArray.array
    end


    def tokenField(field, representedObjectForEditingString:object)
      object.is_a?(Token::Component) ? object.name : object
    end


    def tokenField(field, editingStringForRepresentedObject:object)
      object.is_a?(NSString) ? object : nil
    end


    def tokenField(field, displayStringForRepresentedObject:object)
      if object.is_a?(Token::Component)
        title = object.value
        title = title.upcase if object.type == :time
        title
      else
        object
      end
    end


    def tokenField(field, writeRepresentedObjects:objects, toPasteboard:pboard)
      pboard.declareTypes([Token::Component.description], owner:self)
      # Copy data to the pasteboard
      archived = NSKeyedArchiver.archivedDataWithRootObject(objects)
      pboard.setData(archived, forType: Token::Component.description)
      true
    end


    def tokenField(field, readFromPasteboard:pboard)
      if pboard.types.include?(Token::Component.description)
        data = pboard.dataForType(Token::Component.description)
        NSKeyedUnarchiver.unarchiveObjectWithData(data)
      elsif pboard.types.include?(NSStringPboardType)
       [pboard.stringForType(NSStringPboardType)]
      else
       NSArray.array
      end
    end
  end
  
  class FullTokenDelegate < SimpleTokenDelegate

    def initialize(token_field)
      @token_field = token_field
      @token_menu = NSMenu.new
    end
    attr_accessor :token_field


    def tokenField(_, hasMenuForRepresentedObject:object)
      object.is_a?(Token::Component) && object.attributes.size > 1
    end


    def tokenField(_, menuForRepresentedObject:object)
      @token_menu.removeAllItems unless @token_menu.numberOfItems.zero?
      @token_menu.title = object.name
      object.attributes.each do |value|
        title = Token::Provider.value_for_format(value)
        item = @token_menu.addItemWithTitle(title, action: "click:", keyEquivalent:"")
        item.target = self
        item.identifier = "#{@token_menu.title}.#{object.type}"
        item.representedObject ||= object
      end
      @token_menu
    end


    def tokenField(field, styleForRepresentedObject:object)
      object.is_a?(Token::Component) ? NSDefaultTokenStyle : NSPlainTextTokenStyle
    end


    def click(sender)
      return unless sender.representedObject
      index = sender.menu.indexOfItem(sender)
      sender.representedObject.setValue(index, forKey:"index")
      update
    end


    def update
      values = token_field.objectValue
      data = NSKeyedArchiver.archivedDataWithRootObject(values)
      defaults = NSUserDefaults.standardUserDefaults
      defaults.setObject(data, forKey: CURRENT_FORMAT)
      defaults.synchronize
      token_field.update_display
    end

  end  
end
