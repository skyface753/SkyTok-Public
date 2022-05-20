/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 */

import React, { useEffect, useState } from 'react';
import {
  Button,
  Text,
  ActivityIndicator, 
  FlatList, 
  View 
} from 'react-native';


import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import NewFeedScreen from './src/screens/videoUploadScreen';

const Stack = createNativeStackNavigator();

const App = () => {
  return (
    <NavigationContainer>
      <Stack.Navigator>
        <Stack.Screen
          name="Home"
          component={HomeScreen}
          options={{ title: 'Welcome' }}
        />
        <Stack.Screen name="Videos" component={ProfileScreen} />
        <Stack.Screen name="UploadVideo" component={NewFeedScreen} />
      </Stack.Navigator>
    </NavigationContainer>
  );
};

const HomeScreen = ({ navigation }) => {
  return (
    <View style={{ flex: 1, alignItems: 'center', justifyContent: 'center' }}>
    <Button
      title="Show Videos for User #1"
      onPress={() =>
        navigation.navigate('Videos', { name: 'sjoerz' })
      }
    />
    <Button
      title="Upload Video"
      onPress={() =>
        navigation.navigate('UploadVideo', { name: 'sjoerz' })
      }
    />
    </View>
  );
};
const ProfileScreen = ({ navigation, route }) => {
  const [isLoading, setLoading] = useState(true);
  const [data, setData] = useState([]);

  const getMovies = async () => {
    // Timeout for testing 1 second
    await new Promise(resolve => setTimeout(resolve, 1000));
    try {
      const response = await fetch(
        'http://localhost/videos/getVideosForUserByTags', {
          method: 'POST',
          headers: {
            Accept: 'application/json',
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            userId: '1',
          })
        }
      );
      const json = await response.json();
      setData(json);
      return json;
    } catch (error) {
      console.error(error);
    } finally {
      setLoading(false);
    }
 }


  useEffect(() => {
    getMovies();
  }, []);

  return (
    <View style={{ flex: 1, padding: 24 }}>
      {isLoading ? <ActivityIndicator/> : (
        <FlatList
          data={data}
          keyExtractor={({ id }, index) => id}
          renderItem={({ item }) => (
            <Text>{item.id}, {item.descryption}</Text>
          )}
        />
      )}
    </View>
  );
};


export default App;
