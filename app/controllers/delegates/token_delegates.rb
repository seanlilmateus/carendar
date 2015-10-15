module Carendar
  class SimpleTokenDelegate
    def tokenField(field, completionsForSubstring:substring,
                indexOfToken:index, indexOfSelectedItem:selected_index)
      NSArray.array
    end
    
    def tokenField(field, representedObjectForEditingString:represented_object)
      if represented_object.is_a?(Token::Component)
         represented_object.name
      else
        represented_object
      end
    end
       
    def tokenField(field, displayStringForRepresentedObject:represented_object)
      if represented_object.is_a?(Token::Component)
        title = represented_object.current_value
        title = title.upcase if represented_object.type == :period
        title
      else
        represented_object
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
        Array(NSKeyedUnarchiver.unarchiveObjectWithData(data))
      #elsif pboard.types.include?(NSStringPboardType)
      #  [pboard.stringForType(NSStringPboardType)]
      else
        nil
      end
    end
  end
  
  class FullTokenDelegate < SimpleTokenDelegate
    
    def initialize(token_field)
      @token_field = token_field
      @token_menu = NSMenu.new
    end
    attr_accessor :token_field
    
    def tokenField(_, hasMenuForRepresentedObject:represented_object)
      represented_object.is_a?(Token::Component) && represented_object.attributes.count > 1
    end
    
    def tokenField(_, menuForRepresentedObject:represented_object)
      @token_menu.removeAllItems unless @token_menu.numberOfItems.zero?
      @token_menu.title = represented_object.name
      represented_object.attributes.each do |value|
        title = Token::DateTokenizer.value_for_format(value)
        item = @token_menu.addItemWithTitle(title, action: "edit_cell_action:", keyEquivalent:"")
        item.target = self
        item.identifier = "#{@token_menu.title}.#{represented_object.type}"
        item.action = 'edit_cell_action:'
      end
      @token_menu
    end
    
    def _tokenField(field, shouldAddObjects:tokens, atIndex:index)
      if field.objectValue[index] && field.objectValue[index].is_a?(Token::Component)
        field.objectValue[index].name = tokens[0]
        [field.objectValue[index]]
      else
        tokens
      end
    end
    
    def tokenField(field, shouldAddObjects:tokens, atIndex:index)
      if tokens.all? { |item| item.is_a?(Token::Component) || item.is_a?(NSString) }
        tokens
      else
        NSArray.array
      end
    end

    
    def edit_cell_action sender
      if sender
        objects = token_field.objectValue
        tv = token_field.cell.fieldEditorForView(token_field)
        selections = tv.selectedRanges
        range = selections.first.rangeValue
        token_array = objects.mutableCopy
        if token_array[range.location]
          token_array[range.location].current_index = sender.menu.indexOfItem(sender)
        end
      end
    end    
    
    def tokenField(field, styleForRepresentedObject:represented_object)
      #represented_object.is_a?(Token::Component) ? 0 : 1
      represented_object.is_a?(Token::Component) ? NSDefaultTokenStyle : NSPlainTextTokenStyle
    end
    
    def draggingUpdated(sender)
      puts "Sender > #{sender}"
      NSDragOperationNone
    end
  end  
end
