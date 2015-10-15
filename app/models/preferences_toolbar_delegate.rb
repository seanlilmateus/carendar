module Carendar
  class PreferencesToolbarDelegate
    GENERAL_IDENTIFIER   = "General Preference Identifier"
    APPEARANCE_IDENTIFER = "Appearance Preference Identifer"
    # @ret NSToolbarItem
    def toolbar(toolbar, itemForItemIdentifier:item_id, willBeInsertedIntoToolbar:flag)
      item = nil
      if (item_id == GENERAL_IDENTIFIER)
        item = NSToolbarItem.alloc.initWithItemIdentifier GENERAL_IDENTIFIER
        item.image = NSImage.imageNamed(NSImageNamePreferencesGeneral)
        item.label = localized_string("General")
        item.target = self
        item.action = 'toolbarItemClicked:'
      end
      item
    end
  
    # @ret Array<String>
    def toolbarDefaultItemIdentifiers(toolbar)
      [
        GENERAL_IDENTIFIER,
        NSToolbarFlexibleSpaceItemIdentifier,
      ]
    end
  
    # @ret Array<String>
    def toolbarSelectableItemIdentifiers(toolbar)
      [GENERAL_IDENTIFIER]
    end
  
    # @ret Array<String>
    def toolbarAllowedItemIdentifiers(toolbar)
      [
        GENERAL_IDENTIFIER, 
        NSToolbarFlexibleSpaceItemIdentifier,
        NSToolbarSeparatorItemIdentifier,
        NSToolbarSpaceItemIdentifier,
      ]
    end
    
    def validateToolbarItem item
      item.itemIdentifier == GENERAL_IDENTIFIER
    end
    
    def toolbarItemClicked(sender)
      #puts sender
    end
  end
end